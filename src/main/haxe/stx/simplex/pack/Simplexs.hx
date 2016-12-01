package stx.simplex.pack;

import stx.simplex.core.Data;

class Simplexs{
  @:noUsing static public function generator<O,R>(fn:Thunk<O>):Producer<O,Noise>{
    function rec(i:Control<Noise>):Producer<O,Noise>{
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
  static public function tapR<I,O,R>(prc:Simplex<I,O,R>,fn:R->Void):Simplex<I,O,R>{
    return switch(prc){
      case Wait(arw)          : Wait(arw.then(tapR.bind(_,fn)));
      case Emit(v,nxt)        : Emit(v,tapR(nxt,fn));
      case Halt(Production(r)):
        fn(r);
        Halt(Production(r));
      case Halt(Terminated(cause)) : prc;
      case Held(ft)     : Held(ft.map(tapR.bind(_,fn)));
    }
  }
  static public function tap<I,O,R>(prc:Simplex<I,O,R>,fn:O->Void):Simplex<I,O,R>{
    return switch(prc){
      case Wait(arw)    : Wait(arw.then(tap.bind(_,fn)));
      case Emit(v,nxt)  :
        fn(v);
        Emit(v,tap(nxt,fn));
      case Halt(e)      :
        Halt(e);
      case Held(ft)     : Held(ft.map(tap.bind(_,fn)));
    }
  }
  static public function tapI<I,O,R>(prc:Simplex<I,O,R>,fn:I->Void):Simplex<I,O,R>{
    return switch(prc){
      case Wait(arw)    : Wait(
        function(v){
          v.each(
            function(x){
              fn(x);
            }
          );
          return tapI(arw(v),fn);
        }
      );
      case Emit(v,nxt)  :
        Emit(v,tapI(nxt,fn));
      case Halt(e)      :
        Halt(e);
      case Held(ft)     : Held(ft.map(tapI.bind(_,fn)));
    }
  }
  static public function push<I,O,R>(prc:Simplex<I,O,R>,p:I):Simplex<I,O,R>{
    return switch prc {
      case Wait(arw)    : arw(p);
      case Emit(v,nxt)  : Emit(v,push(nxt,p));
      case Halt(e)      : Halt(e);
      case Held(ft)     : Held(ft.map(push.bind(_,p)));
    }
  }
  static public function end<I,O,R>(prc:Simplex<I,O,R>,e:R):Simplex<I,O,R>{
    return switch prc {
      case Wait(arw)    : Halt(e);
      case Emit(v,nxt)  : Halt(e);
      case Halt(e)      : Halt(e);
      case Held(ft)     : Held(ft.map(end.bind(_,e)));
    }
  }
  static public function map<I,O,O2,R>(prc:Simplex<I,O,R>,fn:O->O2):Simplex<I,O2,R>{
    return switch (prc){
      case Emit(head,tail)  : Emit(fn(head),map(tail,fn));
      case Wait(arw)        :
        var arw2 = arw.then((function(x){ return map(x,fn);}));
        Wait(arw2);
      case Halt(e)          : Halt(e);
      case Held(ft)         : Held(ft.map(map.bind(_,fn)));
    }
  }
  static public function mapR<I,O,R,R1>(prc:Simplex<I,O,R>,fn:R->R1):Simplex<I,O,R1>{
    return switch(prc){
      case Emit(head,tail)          : Emit(head,mapR(tail,fn));
      case Wait(arw)                : Wait(arw.then(mapR.bind(_,fn)));
      case Halt(Production(v))      : Halt(Production(fn(v)));
      case Halt(Terminated(cause))  : Halt(Terminated(cause));
      case Held(ft)                 : Held(ft.map(mapR.bind(_,fn)));
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
  static public function flatMapR<I,O,R,R2>(prc:Simplex<I,O,R>,fn:R->Simplex<I,O,R2>):Simplex<I,O,R2>{
    return switch (prc){
      case Emit(head,tail)              : Emit(head,flatMapR(tail,fn));
      case Wait(arw)                    : Wait(arw.then(flatMapR.bind(_,fn)));
      case Halt(Production(o))          : fn(o);
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Held(ft)                     : Held(ft.map(flatMapR.bind(_,fn)));
    }
  }
  static public function fold<I,O,R>(prc:Simplex<I,O,R>,fn:R->O->R,r:R):Simplex<I,O,R>{
    return switch(prc){
      case Emit(head,tail)  : fold(tail,fn,fn(r,head));
      case Wait(arw)        : Wait(arw.then(fold.bind(_,fn,r)));
      case Halt(e)          : Halt(fn(r,null));
      case Held(ft)         : Held(ft.map(fold.bind(_,fn,r)));
    }
  }
  /*static public function plexfold<I,O,R,Z>(prc:Simplex<I,O,R>,zi:Z->I,oz:O->Z,rz:R->Z):Simplex<Z,Z,Z>{
    return prc.mapI(zi).map(oz).mapR(rz);
  }*/
  static public function passthrough<I,O,R>(prc:Simplex<I,O,R>):Simplex<Either<I,O>,Either<I,O>,R>{
    return switch(prc){
      case Emit(head,tail)  : Emit(Right(head),passthrough(tail));
      case Wait(fn) : Wait(
        function(i:Control<Either<I,O>>){
          return switch(i){
            case Continue(Right(l))  : Emit(Right(l),passthrough(prc));
            case Continue(Left(r))   : passthrough(fn(r));
            case Discontinue(cause)  : Halt(Terminated(cause));
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
    return function piper(lhs0:Simplex<I,O,R>,rhs0:Simplex<O,O2,R>):Simplex<I,O2,R>{
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
          Held(next.asFuture());
        }else{
          val;
        }
    }
  }
  static public function mergeWith<I,O,R>(prc0:Simplex<I,O,R>,prc1:Simplex<I,O,R>,merger:R->R->R):Simplex<I,O,R>{
    //trace('!!!!!! $prc0 $prc1 !!!!!!!!!');
    return switch([prc0,prc1]){
      case [Halt(Production(l)),Halt(Production(r))]    : Halt(Production(merger(l,r)));
      case [Halt(Terminated(l)),Halt(Terminated(r))]    : Halt(l.next(r)); 
      case [Emit(v0,next0),Emit(v1,next1)]              : Emit(v0,Emit(v1,mergeWith(next0,next1,merger)));
      case [Emit(v0,next),Wait(fn)]                     : Emit(v0,mergeWith(next,Wait(fn),merger));
      case [Wait(fn),Emit(v,next)]                      : Emit(v,mergeWith(next,Wait(fn),merger));
      case [Halt(e),spx]                                : mergeWith(spx,Halt(e),merger);
      case [Wait(fn),spx]                               : Wait(fn.then(mergeWith.bind(_,spx,merger)));
      case [Emit(v,next),Halt(e)]                       : Emit(v,mergeWith(next,Halt(e),merger));
      case [Held(ft),Halt(e)]                           : Held(ft.map(mergeWith.bind(_,Halt(e),merger)));
      /*
      case [Held(ft0),Held(ft1)]            :
        var l = ft0.getOption();
        var r = ft0.getOption();
        if(l!=None && r != None){
          Options.get(Options.ap2(mergeWith.bind(_,_,merger),l,r));
        }else if(l!=None){
          Held(ft0.map(mergeWith.bind(_,Held(ft1),merger)));
        }else if(r!=None){
          Held(ft1.map(mergeWith.bind(Held(ft0),_,merger)));
        }else{
          var trigger   = Future.trigger();
          var cancelled = false;
          function canceller(){
            cancelled = true;
          }
          ft0.handle(
            function(x){
              if(!cancelled){
                canceller();
                trigger.trigger(
                  mergeWith(x,Held(ft1),merger)
                );
              }
            }
          );
          ft1.handle(
            function(x){
              if(!cancelled){
                canceller();
                trigger.trigger(
                  mergeWith(Held(ft0),x,merger)
                );
              }
            }
          );
          Held(trigger.asFuture());
        }*/
      case [Held(ft),spx]                   : mergeWith(spx,Held(ft),merger);
      case [spx,Held(ft)]                   : Held(ft.map(mergeWith.bind(spx,_,merger)));
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
  }*/
}

