package stx;

import haxe.ds.Option;

import tink.CoreApi;
using stx.async.Arrowlet;
using stx.Pointwise;

import tink.CoreApi;

import stx.data.Thunk;
import stx.data.Sink;


import stx.simplex.data.Producer;

import stx.simplex.data.Simplex in ESimplex;

typedef Fn<I,O> = I -> O;
@:forward abstract Simplex<I,O,R>(ESimplex<I,O,R>) from ESimplex<I,O,R> to ESimplex<I,O,R>{
  public function new(v){
    this = v;
  }
  @:from static public function fromThunk<T>(thunk:Void->T):Simplex<Noise,T,Error>{
    return Simplexs.generator(thunk);
  }
  @:from static public function fromFunction<I,O>(fn:I->O):Simplex<I,O,Error>{
    var method :Fn<I,Simplex<I,O,Error>>= null;
        method = function(i){
          var o = null;
          try{
            o = Emit(fn(i),Wait(method));
          }catch(e:Error){
            o = Halt(e);
          }catch(e:Dynamic){
            var err = Error.withData(500,Std.string(e),e);
            o = Halt(err);
          }
          return o;
      };
    return Wait(method);
  }
  @:from static public function fromArrow<I,O,R>(arw:Arrowlet<I,O>){
    return Wait(
      function rec(v:I){
        return Held(arw.then(Emit.bind(_,Wait(rec))).apply(v));
      }
    );
  }
  public function map(fn){
    return Simplexs.map(this,fn);
  }
  public function mapI<I1>(fn:I1->I){
    return Simplexs.mapI(this,fn);
  }
  public function mapR(fn){
    return Simplexs.mapR(this,fn);
  }
  public function flatMap(fn){
    return Simplexs.flatMap(this,fn);
  }
  public function plexfold<Z>(zi:Z->I,oz:O->Z,rz:R->Z){
    return Simplexs.plexfold(this,zi,oz,rz);
  }
  public function passthrough<I,O,R>(){
    return Simplexs.passthrough(this);
  }
}
class Simplexs{
  static private inline function future<A>(v:A):Future<A>{
    var ft = new FutureTrigger();
        ft.trigger(v);
      return ft;
  }
  static public function generator<O,R>(fn:Thunk<O>):Producer<O,Error>{
    function rec(i:Noise):Producer<O,Error>{
      var val = null;
      var err = null;
      try{
        val= fn();
      }catch(e:Error){
        err = e;
      }catch(e:Dynamic){
        err = Error.withData(500,Std.string(e),e);
      }
      return if(err!=null){
          Halt(err);
        }else{
          Emit(val,Wait(rec));
        }
    }
    return Wait(rec);
  }
  static public function push<I,O,R>(prc:Simplex<I,O,R>,p:I):Simplex<I,O,R>{
    return switch prc {
      case Wait(arw)    : arw(p);
      case Emit(v,nxt)  : Emit(v,push(nxt,p));
      case Halt(e)      : Halt(e);
      case Held(ft)     : Held(ft.then(push.bind(_,p)));
    }
  }
  static public function end<I,O,R>(prc:Simplex<I,O,R>,e:R):Simplex<I,O,R>{
    return switch prc {
      case Wait(arw)    : Halt(e);
      case Emit(v,nxt)  : Halt(e);
      case Halt(e)      : Halt(e);
      case Held(ft)     : Held(ft.then(end.bind(_,e)));
    }
  }
  static public function map<I,O,O2,R>(prc:Simplex<I,O,R>,fn:O->O2):Simplex<I,O2,R>{
    return switch (prc){
      case Emit(head,tail)  : Emit(fn(head),map(tail,fn));
      case Wait(arw)        :
        var arw2 = arw.then((function(x){ return map(x,fn);}:Fn<Simplex<I,O,R>,Simplex<I,O2,R>>));
        Wait(arw2);
      case Halt(e)          : Halt(e);
      case Held(ft)         : Held(ft.map(map.bind(_,fn)));
    }
  }
  static public function mapR<I,O,R,R1>(prc:Simplex<I,O,R>,fn:R->R1):Simplex<I,O,R1>{
    return switch(prc){
      case Emit(head,tail)  : Emit(head,mapR(tail,fn));
      case Wait(arw)        : Wait(arw.then(mapR.bind(_,fn)));
      case Halt(e)          : Halt(fn(e));
      case Held(ft)         : Held(ft.map(mapR.bind(_,fn)));
    }
  }
  static public function append<I,O,R>(prc0:Simplex<I,O,R>,prc1:Thunk<Simplex<I,O,R>>):Simplex<I,O,R>{
    return switch (prc0){
      case Emit(head,tail)  : Emit(head,append(tail,prc1));
      case Wait(arw)        : Wait(arw.then(append.bind(_,prc1)));
      case Halt(null)       : prc1();
      case Halt(e)          : Halt(e);
      case Held(ft)         : Held(ft.map(append.bind(_,prc1)));
    }
  }
  static public function flatMap<I,O,O2,R>(prc:Simplex<I,O,R>,fn:O->Simplex<I,O2,R>):Simplex<I,O2,R>{
    return switch (prc){
      case Emit(head,tail)  : append(fn(head),Pointwise.toThunk(flatMap(tail,fn)));
      case Wait(arw)        : Wait(arw.then(flatMap.bind(_,fn)));
      case Halt(e)          : Halt(e);
      case Held(ft)         : Held(ft.map(flatMap.bind(_,fn)));
    }
  }
  static public function plexfold<I,O,R,Z>(prc:Simplex<I,O,R>,zi:Z->I,oz:O->Z,rz:R->Z):Simplex<Z,Z,Z>{
    return prc.mapI(zi).map(oz).mapR(rz);
  }
  static public function passthrough<I,O,R>(prc:Simplex<I,O,R>):Simplex<Either<I,O>,Either<I,O>,R>{
    return switch(prc){
      case Emit(head,tail)  : Emit(Right(head),passthrough(tail));
      case Wait(fn) : Wait(
        function(i:Either<I,O>){
          return switch(i){
            case Right(l)  : Emit(Right(l),passthrough(prc));
            case Left(r)   : passthrough(fn(r));
          }
        }
      );
      case Halt(e)  : Halt(e);
      case Held(ft) : Held(ft.map(passthrough));
    }
  }
  /*
  static public function chain<I,O,R,R1>(prc0:Simplex<I,O,R>,prc1:Simplex<R,O,R1>){
    return switch([prc0,prc1]){
      case [Halt(e),Wait(fn)] :
        chain(prc0,fn(e));
      case [l,Emit(v,next)]   :
        chain(Emit(v))
    }
  }*/
  static public function pipe<I,O,O2,R>(prc0:Simplex<I,O,R>,prc1:Simplex<O,O2,R>):Simplex<I,O2,R>{
    var finishedLeft  = None;
    var finishedRight = None;
    //trace('$prc0 $prc1');
    return function piper(lhs0:Simplex<I,O,R>,rhs0:Simplex<O,O2,R>){
      //trace('$lhs0 $rhs0');
      return switch([lhs0,rhs0]){
        case [Halt(e),_] :
          finishedLeft = Some(e);
          Halt(e);
        case [_,Halt(e)] :
          Halt(e);
        case [Held(ft0),Held(ft1)]:
          var trigger = Future.trigger();
          var lhs     = None;
          var rhs     = None;
          function handler(){
            switch([lhs,rhs]){
              case [Some(a),Some(b)]:
                trigger.trigger(piper(a,b));
              default:
            }
          }
          ft0.handle(function(lhv){lhs = Some(lhv);handler();});
          ft1.handle(function(rhv){rhs = Some(rhv);handler();});
          Held(trigger);
        case [Wait(arw),Emit(v,nxt)]:
          Emit(v,
            Wait(
              arw.then(piper.bind(_,nxt))
            )
          );
        case [Emit(v,nxt),Wait(arw)]:
          var res = arw(v);
          piper(nxt,res);
        case [Emit(v,nxt),_]      : piper(nxt,push(prc1,v));
        case [Wait(arw),rhs1]     :
          return Wait(arw.then(piper.bind(_,rhs1)));
        case [_,Emit(v,nxt)]      : Emit(v,piper(lhs0,nxt));
        case [Held(ft),Wait(arw)] :
          var trigger = Future.trigger();
          ft.handle(
            function(lhs1){
              trigger.trigger(piper(lhs1,Wait(arw)));
            }
          );
          Held(trigger);
        case [_,Wait(arw)]            : piper(lhs0,rhs0);
       }
    }(prc0,prc1);
  }
  static public function press<I,O,R>(prc0:Simplex<I,O,R>):Simplex<I,O,R>{
    return switch (prc0){
      case Emit(head,tail)  : Emit(head,press(tail));
      case Wait(arw)        : Wait(arw.then(press));
      case Halt(e)          : Halt(e);
      case Held(ft)         :
        var val : Simplex<I,O,R> = null;
        var cancelled       = false;
        ft.handle(
          function(x){
            if(!cancelled){
              val = x;
              cancelled = true;
            }
          }
        );
        if(val==null){
          Held(ft);
        }else{
          val;
        }
    }
  }
  @:noUsing static public function one<I,O,R>(v:O):Simplex<I,O,R>{
    return Emit(v,Halt(null));
  }
  static public function each<I,O,R>(prc:Simplex<I,O,R>,fn:O->Void):Simplex<I,O,R>{
    return map(prc,
      function(x){
        fn(x);
        return x;
      }
    );
  }
  static public function reduce<I,O,R,Z>(prc:Simplex<I,O,R>,fn:Z->O->Z,unit:Z):Simplex<I,Z,R>{
    var next = unit;
    return switch (prc){
      case Emit(head,tail)  : next = fn(next,head); reduce(tail,fn,next);
      case Wait(arw)        : Wait(arw.then(reduce.bind(_,fn,next)));
      case Halt(e)          : Emit(next,Halt(e));
      case Held(ft)         : Held(ft.map(reduce.bind(_,fn,next)));
    }
  }
  /*static public function drive<I,O>(prc:Simplex<I,O>,sig:Signal<I>):Simplex<I,O>{
    var ft  = Future.trigger();
    var prc = Held(ft);

    sig.next().handle(
    function driver(i:I){
      ft.trigger(switch (prc){
          case Emit(head,tail)  : Emit(head,tail);
          case Wait(arw)        : Held(arw.then(drive.bind(_,sig)).apply(i));
          case Halt(e)          : Halt(e);
          case Held(ft)         : Held(ft);
        });
    });
    return prc;
  }*/
  static public function mapI<I,IN,O,R>(prc:Simplex<I,O,R>,fn:IN->I):Simplex<IN,O,R>{
    return switch (prc) {
      case Emit(head,tail) : Emit(head,mapI(prc,fn));
      case Held(ft)        : Held(ft.map(mapI.bind(_,fn)));
      case Halt(e)         : Halt(e);
      case Wait(arw)       : Wait(
        function(x:IN){
          var g : I = fn(x);
          var o     = arw(g);
          var o2    = mapI(o,fn);
          return o2;
        }
      );
    };
  }
  static public function compile<I,O,R>(prc:Simplex<I,O,R>,s:Signal<I>):Signal<Either<O,R>>{
    var out           = Signal.trigger();
    var ft_stack      = [];
    var arw_stack     = [];
    var stack         = [];
    var done          = false;

    function wake(){
      if(!done){
        switch (prc) {
        case Held(ft)  :
          if(ft_stack.indexOf(ft) == -1){
            ft_stack.push(ft);
            ft.handle(
              function(x){
                prc = x;
                ft_stack.remove(ft);
                wake();
              }
            );
          }
        case Emit(head,tail) :
          out.trigger(Left(head));
          prc = tail;
          if(stack.length>0){
            wake();
          }
        case Halt(e)   :
          out.trigger(Right(e));
          done  = true;
          stack = null;
        case Wait(arw) :
          if(stack.length > 0){
            if(arw_stack.indexOf(arw) == -1){
              arw_stack.push(arw);
              var o = arw(stack.pop());
              prc = o;
              arw_stack.remove(arw);
              wake();
            }
          }
        }
      }
    }
    s.handle(
      function(x){
        if(!done){
          stack.unshift(x);
          wake();
        }
      }
    );
    return out.asSignal();
  }
}
