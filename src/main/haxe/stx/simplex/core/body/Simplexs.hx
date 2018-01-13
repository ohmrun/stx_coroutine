package stx.simplex.core.body;

import stx.simplex.core.pack.Simplex;

class Simplexs{
  @:noUsing static public function tap<I,O,R>(spx:Simplex<I,O,R>,fn:Phase<I,O,R>->Void):Simplex<I,O,R>{
    return spx.tapI(
      function(ctl){
        fn(Ipt(ctl));
      }
    ).tapO(
      function(o){
        fn(Opt(o));
      }
    ).tapR(
      function(r){
        fn(Rtn(r));
      }
    );
  }
  @:noUsing static public function toEmiter<R>(fn:Thunk<R>):Emiter<R>{
    function rec(i:Control<Noise>):Emiter<R>{
      return switch(i){
        case Continue(Noise) : 
          var val = null;
          var err = null;
          try{
            val= fn();
          }catch(e:stx.Error){
            err = e;
          }catch(e:tink.core.Error){
            err = stx.Error.fromTinkError(e);
          }catch(e:Dynamic){
            err = stx.Error.withData(500,Std.string(e),e);
          }
          return if(err!=null){
              Halt(Terminated(Early(err)));
            }else{
              Emit(val,Wait(rec));
          }
        case Discontinue(cause) : Halt(Terminated(cause));
      }
    }
    return Wait(rec);
  }
  static public function tapR<I,O,R>(prc:Simplex<I,O,R>,fn:Return<R>->Void):Simplex<I,O,R>{
    return switch(prc){
      case Wait(arw)          : Wait(arw.then(tapR.bind(_,fn)));
      case Emit(v,nxt)        : Emit(v,tapR(nxt,fn));
      case Halt(cause)        : fn(cause);Halt(cause);
      case Hold(ft)           : Hold(ft.map(tapR.bind(_,fn)));
    }
  }
  static public function tapO<I,O,R>(prc:Simplex<I,O,R>,fn:O->Void):Simplex<I,O,R>{
    return switch(prc){
      case Wait(arw)    : Wait(arw.then(tapO.bind(_,fn)));
      case Emit(v,nxt)  :
        fn(v);
        Emit(v,tapO(nxt,fn));
      case Halt(e)      :
        Halt(e);
      case Hold(ft)     : Hold(ft.map(tapO.bind(_,fn)));
    }
  }
  static public function tapI<I,O,R>(prc:Simplex<I,O,R>,fn:Control<I>->Void):Simplex<I,O,R>{
    return switch(prc){
      case Wait(arw)    : Wait(
        function(v){
          fn(v);
          return tapI(arw(v),fn);
        }
      );
      case Emit(v,nxt)  :
        Emit(v,tapI(nxt,fn));
      case Halt(e)      :
        Halt(e);
      case Hold(ft)     : Hold(ft.map(tapI.bind(_,fn)));
    }
  }
  static public function provide<I,O,R>(prc:Simplex<I,O,R>,p:I):Simplex<I,O,R>{
    return switch prc {
      case Wait(arw)    : arw(Continue(p));
      case Emit(v,nxt)  : Emit(v,provide(nxt,p));
      case Halt(e)      : Halt(e);
      case Hold(ft)     : Hold(ft.map(provide.bind(_,p)));
    }
  }
  static public function halt<I,O,R>(prc:Simplex<I,O,R>,e:R):Simplex<I,O,R>{
    return switch prc {
      case Wait(arw)    : Halt(Production(e));
      case Emit(v,nxt)  : Halt(Production(e));
      case Halt(e)      : Halt(e);
      case Hold(ft)     : Hold(ft.map(halt.bind(_,e)));
    }
  }
  static public function mapI<I,IN,O,R>(prc:Simplex<I,O,R>,fn:IN->I):Simplex<IN,O,R>{
    return switch (prc) {
      case Emit(head,tail) : Emit(head,mapI(prc,fn));
      case Hold(ft)        : Hold(ft.map(mapI.bind(_,fn)));
      case Halt(e)         : Halt(e);
      case Wait(arw)       : Wait(
        function(x:Control<IN>){
          return switch(x){
            case Continue(v):
              var g : I = fn(v);
              var o     = arw(Continue(g));
              mapI(o,fn);
            case Discontinue(cause) : Halt(Terminated(cause));
          }
        }
      );
    };
  }
  static public function map<I,O,O2,R>(prc:Simplex<I,O,R>,fn:O->O2):Simplex<I,O2,R>{
    return switch (prc){
      case Emit(head,tail)  : Emit(fn(head),map(tail,fn));
      case Wait(arw)        :
        var arw2 = arw.then((function(x){ return map(x,fn);}));
        Wait(arw2);
      case Halt(e)          : Halt(e);
      case Hold(ft)         : Hold(ft.map(map.bind(_,fn)));
    }
  }
  static public function mapR<I,O,R,R1>(prc:Simplex<I,O,R>,fn:R->R1):Simplex<I,O,R1>{
    return switch(prc){
      case Emit(head,tail)          : Emit(head,mapR(tail,fn));
      case Wait(arw)                : Wait(arw.then(mapR.bind(_,fn)));
      case Halt(Production(v))      : Halt(Production(fn(v)));
      case Halt(Terminated(cause))  : Halt(Terminated(cause));
      case Hold(ft)                 : Hold(ft.map(mapR.bind(_,fn)));
    }
  }
  static public function mapOrHalt<I,O,O2,R>(prc:Simplex<I,O,R>,fn: O -> Either<Cause,O2>):Simplex<I,O2,R>{
    function recurse(spx){
      return switch(spx){
        case Emit(Right(o),next)    : Emit(o,recurse(next));
        case Emit(Left(cause),_)    : Halt(Terminated(cause));
        case Wait(fn)               : Wait(fn.then(recurse));
        case Hold(ft)               : Hold(ft.map(recurse));
        case Halt(res)              : Halt(res); 
      }
    }
    return recurse(map(prc,fn));
  }
  static public function flatMapR<I,O,R,R2>(prc:Simplex<I,O,R>,fn:R->Simplex<I,O,R2>):Simplex<I,O,R2>{
    return switch (prc){
      case Emit(head,tail)              : Emit(head,flatMapR(tail,fn));
      case Wait(arw)                    : Wait(arw.then(flatMapR.bind(_,fn)));
      case Halt(Production(o))          : fn(o);
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Hold(ft)                     : Hold(ft.map(flatMapR.bind(_,fn)));
    }
  }
  /*
  static public function pull<I,O,O2,R>(prc0:Simplex<I,O,R>,prc1:Simplex<O,O2,R>):Simplex<I,O2,R>{
    return (piper(lhs:Simplex<I,O,R>,rhs:Simplex<O,O2,R>):Simplex<I,O2,R> ->
      switch(lhs,rhs){

      }
    )(prc0,prc1);
  }*/
  static public function pipe<I,O,O2,R>(prc0:Simplex<I,O,R>,prc1:Simplex<O,O2,R>):Simplex<I,O2,R>{
    var finishedLeft  = None;
    var finishedRight = None;
    //trace('$prc0 $prc1');
    return function piper(lhs0:Simplex<I,O,R>,rhs0:Simplex<O,O2,R>):Simplex<I,O2,R>{
      //trace('$lhs0 $rhs0');
      return switch([lhs0,rhs0]){
        case [Halt(e),_] :
          /*
            Upstream closed, Halt
          */
          finishedLeft = Some(e);
          Halt(e);
        case [_,Halt(e)] :
          /*
            Downstream closed, Halt
          */
          Halt(e);
        case [Hold(ft0),Hold(ft1)]:
          /*
            Both in Hold state, wait for both resolutions.
          */
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
          Hold(trigger);
        case [Wait(arw),Emit(v,nxt)]:
          /*
            Left hand in Wait state, but value available. 
            Emit from right, and pass the output of lhs to the remainder of the rhs.
          */
          Emit(v,
            Wait(
              arw.then(piper.bind(_,nxt))
            )
          );
        case [Emit(v,nxt),Wait(arw)] :
          /*
            Value at left hand side received, rhs open, so provide.
          */
            var res = arw(Continue(v));
            piper(nxt,res);
        case [Emit(v,nxt),_]      : 
          /*
            Value emitted, provide right hand Simplex.
          */
          piper(nxt,provide(prc1,v));
        case [Wait(arw),rhs1]     :
          /*
            Anything else will wait for the combined Simplex to be provided to.
          */
          Wait(arw.then(piper.bind(_,rhs1)));
        case [_,Emit(v,nxt)]      : 
          /*
            Right is emiting, let it through, and pipe the remainders
          */
          Emit(v,piper(lhs0,nxt));
        case [Hold(ft),Wait(arw)] :
          /*
            Left is Hold, right is in Wait, hold everything.
          */
          var trigger = Future.trigger();
          ft.handle(
            function(lhs1){
              trigger.trigger(piper(lhs1,Wait(arw)));
            }
          );
          Hold(trigger);
        case [_,Wait(arw)]            : 
          /*
            What is this, I don't
          */
          piper(lhs0,rhs0);
       }
    }(prc0,prc1);
  }
  /*
  static public function pipeR<I,O,R,R2>(lhs:Simplex<I,O,R>,rhs:Simplex<R,O,R2>):Simplex<I,O,R2>{
    return switch([lhs,rhs]){
      case [Halt(Terminated(Unfinished)),Wait]
      case [Halt(Production(out)),_] : 
        rhs.push(out);
      case [Hold(ft),_]               : 
        ft.map((l) -> pipeR(l,rhs));
      case [Emit(head,tail),_]        : 
        Emit(head,pipeR(tail,rhs));
      case [Halt(Terminated(cause)),_]  : 
        Halt(Terminated(cause));
      case [_,Halt(Terminated(cause))]  :
        Halt(Terminated(cause));
      case [_,Halt(Production(out))] :
        Halt(Production(out));
    };
  }
  */
  /**
   *  Will seek to resolve the value of the next upcoming Hold if it exists.
   *  @param prc0 - 
   *  @return Simplex<I,O,R>
   */
  static public function press<I,O,R>(prc0:Simplex<I,O,R>):Simplex<I,O,R>{
    return switch (prc0){
      case Emit(head,tail)  : Emit(head,press(tail));
      case Wait(arw)        : Wait(arw.then(press));
      case Halt(e)          : Halt(e);
      case Hold(ft)         :
        var val : Simplex<I,O,R> = null;
        var cancelled       = false;
        var next            = Future.trigger();
        ft.handle(
          function(x){
            if(!cancelled){
              val = x;
              cancelled = true;
            }else{
              next.trigger(x);
            }
          }
        );
        if(val==null){
          Hold(next.asFuture());
        }else{
          val;
        }
    }
  }
  /**
   *  static public function pursue
   */

  /**
   *  
   *  @param prc0 - 
   *  @param prc1 - 
   *  @param merger - 
   *  @return Simplex<I,O,R>
   */
  static public function mergeWith<I,O,R>(prc0:Simplex<I,O,R>,prc1:Simplex<I,O,R>,merger:R->R->R):Simplex<I,O,R>{
    //trace('!!!!!! $prc0 $prc1 !!!!!!!!!');
    return switch([prc0,prc1]){
      case [Halt(Production(l)),Halt(Production(r))]    : Halt(Production(merger(l,r)));
      case [Halt(Terminated(l)),Halt(Terminated(r))]    : Halt(Terminated(l.next(r))); 
      case [Emit(v0,next0),Emit(v1,next1)]              : Emit(v0,Emit(v1,mergeWith(next0,next1,merger)));
      case [Emit(v0,next),Wait(fn)]                     : Emit(v0,mergeWith(next,Wait(fn),merger));
      case [Wait(fn),Emit(v,next)]                      : Emit(v,mergeWith(next,Wait(fn),merger));
      case [Halt(e),spx]                                : mergeWith(spx,Halt(e),merger);
      case [Wait(fn),spx]                               : Wait(fn.then(mergeWith.bind(_,spx,merger)));
      case [Emit(v,next),Halt(e)]                       : Emit(v,mergeWith(next,Halt(e),merger));
      case [Hold(ft),Halt(e)]                           : Hold(ft.map(mergeWith.bind(_,Halt(e),merger)));
      case [Hold(ft),spx]                               : mergeWith(spx,Hold(ft),merger);
      case [spx,Hold(ft)]                               : Hold(ft.map(mergeWith.bind(spx,_,merger)));
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
      case Hold(ft)         : Hold(ft.map(reduce.bind(_,fn,next)));
    }
  }
  /*static public function drive<I,O>(prc:Simplex<I,O>,sig:Signal<I>):Simplex<I,O>{
    var ft  = Future.trigger();
    var prc = Hold(ft);

    sig.next().handle(
    function driver(i:I){
      ft.trigger(switch (prc){
          case Emit(head,tail)  : Emit(head,tail);
          case Wait(arw)        : Hold(arw.then(drive.bind(_,sig)).apply(i));
          case Halt(e)          : Halt(e);
          case Hold(ft)         : Hold(ft);
        });
    });
    return prc;
  }*/
  /*
  static public function compile<I,O,R>(prc:Simplex<I,O,R>,s:Signal<I>):Signal<Either<O,R>>{
    var out           = Signal.trigger();
    var ft_stack      = [];
    var arw_stack     = [];
    var stack         = [];
    var done          = false;

    function wake(){
      if(!done){
        switch (prc) {
        case Hold(ft)  :
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
  }*/
  static public function returns<I,O,R>(spx:Simplex<I,O,R>):Return<R>{
    return switch(spx){
      case Halt(r)  : r;
      default       : Terminated(Kill);
    }
  }
  static public function recurse<I,O,R,O1,R1>(next:Simplex<I,O,R>->Simplex<I,O,R>){
    return new Y()(function(rec){
      return function(spx:Simplex<I,O,R>):Simplex<I,O,R>{
        return switch(spx){
            case Halt(out)  : Halt(out);
            case Wait(fn)   : Wait(fn.then(rec));
            case Hold(ft)   : Hold(ft.map(rec));
            default         : rec(next(spx));
          }
      }
    });
  }
}

