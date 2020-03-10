package stx.simplex.core.body;

import stx.fn.pack.Y;
import stx.simplex.core.pack.Simplex;

class Simplexs{
  static public function change<I,O,R,R1>():Y<Simplex<I,O,R>,Simplex<I,O,R1>>{
    return function rec(fn:Y<Simplex<I,O,R>,Simplex<I,O,R1>>){
      return function(spx:Simplex<I,O,R>):Simplex<I,O,R1>{
        function f(spx:Simplex<I,O,R>):Simplex<I,O,R1> return fn(rec)(spx);
        return switch(spx.state){
          case Emit(emit)           : emit.mod(f);
          case Wait(arw)            : Spx.wait(arw.mod(f));
          case Hold(h)              : Spx.hold(h.mod(f));
          case Halt(Production(v))  : f(Spx.done(v));
          case Halt(Terminated(c))  : f(Spx.term(c));
          case Seek(v,n)            : Spx.seek(v,f(n));
        }
      }
    }
  }
  static public function transform<I,O,R,I1,O1,R1>():Y<Simplex<I,O,R>,Simplex<I1,O1,R1>>{
    return function rec(fn:Y<Simplex<I,O,R>,Simplex<I1,O1,R1>>){
      return function(spx:Simplex<I,O,R>):Simplex<I1,O1,R1>{
        function f(spx:Simplex<I,O,R>):Simplex<I1,O1,R1> return fn(rec)(spx);
        return switch(spx.state){
          case Emit(emit)           : f(spx);
          case Wait(arw)            : f(spx);
          case Hold(h)              : Spx.hold(h.mod(f));
          case Halt(Production(v))  : f(Spx.done(v));
          case Halt(Terminated(c))  : f(Spx.term(c));
          case Seek(v,n)            : Spx.seek(v,f(n));
        }
      }
    }
  }
  static public function cons<I,O,R>(spx:Simplex<I,O,R>,o:O):Simplex<I,O,R>{
    return Spx.emit(o,spx);
  }
  static public function seek<I,O,R>(spx:Simplex<I,O,R>,advice:Advice):Simplex<I,O,R>{
    return Spx.seek(advice,spx);
  }
  @:noUsing static public function provide<I,O,R>(prc:Simplex<I,O,R>,p:I):Simplex<I,O,R>{
      return (function rec(fn:Y<Simplex<I,O,R>,Simplex<I,O,R>>):Simplex<I,O,R>->Simplex<I,O,R>{
        return function(spx){
          return switch(spx.state){
            case Wait(arw)  : arw(Operator.pusher(p));
            default         : fn(rec)(spx);
          }  
        }
      })(change())(prc);
  }
  static public function map<I,O,O2,R>(prc:Simplex<I,O,R>,fn:O->O2):Simplex<I,O2,R>{
    return (function rec(f:Y<Simplex<I,O,R>,Simplex<I,O2,R>>):Simplex<I,O,R>->Simplex<I,O2,R>{
      return function(spx){
        return switch(spx.state){
          case Emit(emit) :
            var head  = fn(emit.data);
            var tail  = f(rec)(emit.next);
            Spx.emit(head,tail);
          case Wait(arw)  : Spx.wait(arw.mod(f(rec)));
          default         : f(rec)(spx);
        }
      }
    })(transform())(prc);
  }
  static public function mapR<I,O,R,R1>(prc:Simplex<I,O,R>,fn:R->R1):Simplex<I,O,R1>{
    return (
      function rec(f:Y<Simplex<I,O,R>,Simplex<I,O,R1>>):Simplex<I,O,R>->Simplex<I,O,R1>{
        return function(spx){
          return switch(spx.state){
            case Halt(Production(v))  : Spx.done(fn(v));
            default                   : f(rec)(spx);
          }
        }
      }
    )(change())(prc);
  }
  static public function mapOrHalt<I,O,O2,R>(prc:Simplex<I,O,R>,fn: O -> Either<Cause,O2>):Simplex<I,O2,R>{
    return (
      function rec(f:Y<Simplex<I,O,R>,Simplex<I,O2,R>>):Simplex<I,O,R>->Simplex<I,O2,R>{
        return function (spx){
          return switch(spx.state){
            case Emit(emit) : 
              var tail = fn(emit.data);
              switch(tail){
                case Left(cause) : Spx.term(cause);
                case Right(o)    : Spx.emit(o,f(rec)(emit.next));
              }
            case Wait(arw)  : Spx.wait(arw.mod(f(rec)));
            default         : f(rec)(spx);
          }
        }
      }
    )(transform())(prc);
  }
  static public function flatMapR<I,O,R,R2>(prc:Simplex<I,O,R>,fn:R->Simplex<I,O,R2>):Simplex<I,O,R2>{
    return (
      function rec(f:Y<Simplex<I,O,R>,Simplex<I,O,R2>>):Simplex<I,O,R>->Simplex<I,O,R2>{
        return function(spx){
          return switch(spx.state){
            case Halt(Production(v))  : fn(v);
            default                   : f(rec)(spx);
          }
        }
      }
    )(change())(prc);
  }
  static public function pipe<I,O,O2,R>(prc0:Simplex<I,O,R>,prc1:Simplex<O,O2,R>):Simplex<I,O2,R>{
    return Spx.wait(
      function(op:Operator<I>):Simplex<I,O2,R>{
        var lhs : Simplex<I,O,R>        = prc0;
        var rhs : Simplex<O,O2,R>       = prc1;
        var cause    = null;
        var control  = op(Op.okay());
        //trace('$control: ($lhs) ($rhs)');
        var next = switch([control,lhs.state,rhs.state]){
          case [Okay|Pull,Seek(Hung(c),_),_]                  : Spx.term(c);
          case [Exit(c),_,_]                                  : Spx.term(c);
          case [Push(v),_,_]                                  :
            var next : Simplex<I,O,R> = provide(lhs,v);
            pipe(next,rhs);
          case [_,Halt(Terminated(Early(c))),Wait(arw)]                          : 
            Spx.term(
              __.fault().because('Upstream halt on downstream wait').next(c)
            );
          case [_,Halt(c),Emit(e)]                            : 
            Spx.emit(e.data,pipe(lhs,e.next));
          case [_,Halt(c),_]                                  : Spx.halt(c);
          case [_,Emit(emit),Halt(Terminated(Early(c)))]             :
            Spx.term(
              __.fault().because('Downstream Halt on Upstream Emit').next(c)
            );
          case [_,_,Halt(c)]                                  : Spx.halt(c);
          case [Pull|Okay,Emit(e),Wait(arw)]                  :
            rhs = arw(Operator.pusher(e.data));
            pipe(e.next,rhs);
          case [Pull|Okay,Hold(e),Wait(arw)]                  :
            Spx.hold(e.mod(pipe.bind(_,rhs)));
          case [Pull|Okay,Wait(l),Wait(_)]:
            Spx.wait(l.mod(pipe.bind(_,rhs)));
          case [_,Hold(ft),Emit(emit)]                        :
            Spx.hold(
              function recure(){ 
                return switch(ft.value()){
                  case Some(next) : Spx.emit(emit.data,pipe(next,emit.next));
                  case None       : Spx.emit(emit.data,Spx.hold(recure));
                };
              }
            );
          case [Pull|Okay,_,Emit(e)]                          : 
            Spx.emit(e.data,pipe(lhs,e.next));
          case [_,_,Hold(ft)]                                 :
            Spx.hold(ft.mod(pipe.bind(lhs)));
          case [_,_,Seek(advice,next)]                        :
            Spx.seek(advice,pipe(lhs,next));
          case [_,Seek(advice,next),_]                        :
            Spx.seek(advice,pipe(next,rhs));
          case [_,Wait(arw),Emit(e)]                          :
            Spx.wait(
              (op) -> switch(op(Op.okay())){
                case Pull | Okay  : Spx.emit(e.data,pipe(lhs,e.next));
                case Push(v)      : pipe(arw(Operator.pusher(v)),e);
                case Exit(c)      : Spx.term(c);
              }
            );
        }
        return next;
      }
    );
  }
  @:noUsing static public function one<I,O,R>(v:O):Simplex<I,O,R>{
    return Spx.emit(v,Spx.stop());
  }
  static public function each<I,O,R>(prc:Simplex<I,O,R>,fn:O->Void):Simplex<I,O,R>{
    return map(prc,
      (x) -> {
        fn(x);
        return x;
      }
    );
  }
  static public function returns<I,O,R>(spx:Simplex<I,O,R>):Return<R>{
    return switch(spx.state){
      case Halt(r)  : r;
      default       : Terminated(Stop);
    }
  }
  static public function toString<I,O,R>(self){
    function recurse(self:Simplex<I,O,R>):String{
      return switch(self.state){
        case Emit(emit)       : '!<${emit.data}>${recurse(emit.next)}';
        case Wait(arw)        : '->';
        case Hold(h)          : '[?]';
        case Halt(Terminated(Stop))          : '#.';
        case Halt(e)          : '#$e';
        case Seek(v,n)        : '$v:$n';
      }
    }
    return recurse(self);
  }
  static public function fold<I,O,R,Z>(prc:Simplex<I,O,R>,fn:Z->O->Z,unit:Z):Simplex<I,Z,R>{
    return null;
  }
}

