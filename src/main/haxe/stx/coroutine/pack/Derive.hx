package stx.coroutine.pack;

typedef DeriveDef<R,E> = CoroutineSum<Noise,Noise,R,E>;

@:using(stx.coroutine.pack.Derive.DeriveLift)
@:forward abstract Derive<R,E>(DeriveDef<R,E>) from DeriveDef<R,E> to DeriveDef<R,E>{
  public function new(self:DeriveDef<R,E>) this = self;
  @:noUsing static public function lift<R,E>(self:DeriveDef<R,E>) return new Derive(self);
  @:from static public function fromCoroutine<I,O,R,E>(spx:Coroutine<Noise,Noise,R,E>):Derive<R,E>{
    return new Derive(spx);
  }
  @:noUsing static public function fromThunk<R,E>(thk:Thunk<R>):Derive<R,E>{
    return lift(__.lazy(
      () -> __.prod(thk())
    ));
  }
  @:to public function toCoroutine():Coroutine<Noise,Noise,R,E>{
    return this;
  }
  /*
  @:from static public function fromDeriveOfFuture<T,E>(src:Derive<Future<T>,E>):Derive<T,E>{
    function recurse(src:Derive<Future<T>,E>):Derive<T,E>{
      return switch(src){
        case Hold(ft)           : Hold(ft.mod(recurse));
        case Halt(ret)          : Halt(ret);
        case Emit(head,tail)    : Hold(head.map(
          function(v:T){
            return Emit(v,recurse(tail));
          }
        ));
        case Wait(arw)          : Wait(arw.then(recurse)); 
      }
    }
    return recurse(src);
  }*/
}

class DeriveLift{
  
  static public function toSource<O,R,E>(self:DeriveDef<R,E>):Source<O,R,E>{
    function recurse(self){
      return switch(self){
        case Halt(Terminated(cause))  : Halt(Terminated(cause));
        case Halt(Production(ret))    : Halt(Production(ret));
        case Halt(e)                  : Halt(e);
        case Emit(Noise,next)         : __.stop();
        case Wait(arw)                : Wait(arw.mod(recurse));
        case Hold(ft)                 : Hold(ft.mod(recurse));
        case _                        : throw "This is a regression";
      }
    }
    return recurse(self);
  }
  static public function complete<R,E>(self:DeriveDef<R,E>,cb:R->Void):Effect<E>{
    function recurse(self){
      return switch(self){
        case Halt(Terminated(cause))  : __.term(cause);
        case Halt(Production(ret))    :
          cb(ret); 
          __.stop();
        case Emit(head,rest)          : __.emit(head,complete(rest,cb));
        case Wait(arw)                : __.wait(arw.mod(recurse));
        case Hold(ft)                 : __.hold(ft.mod(recurse));
      } 
    }
    return Effect.lift(recurse(self));
  }
  // static public function modulate<R,Ri,E>(self:DeriveDef<R,E>,fn:Modulate<R,Ri,CoroutineFailure<E>>):Derive<Ri,E>{
  //   function f(self:DeriveDef<R,E>):DeriveDef<R,E>{
  //     return switch(self){
  //       case Emit(o,next)                           : __.emit(o,f(next));
  //       case Wait(tran)                             : __.wait(tran.mod(f));
  //       case Hold(held)                             : __.hold(held.mod(f));
  //       case Halt(Terminated(Exit(rejection)))      : 
  //         final result = 
  //           fn.prj().produce(__.reject(rejection)).map(
  //             res -> res.fold(
  //               ok -> __.prod(ok),
  //               no -> __.term(no)
  //             )
  //           );
  //         __.hold(Held.fromProduce(result));
  //         null;
  //       // case Halt(Production(r))                    : __.hold(Held.Ready(fn.prj().produce(__.accept(r)).map(
  //       //   (res) -> res.fold(
  //       //     ok -> __.prod(ok),
  //       //     no -> __.term(no)
  //       //   )
  //       // )));
  //       null;
  //       case Halt(Terminated(Stop))                 : __.stop();
  //       default                                     : __.stop();
  //     }
  //   }
  //   return Derive.lift(self);
  // }
  static public function zip<R,Ri,E>(self:DeriveDef<R,E>,that:DeriveDef<Ri,E>):Derive<Couple<R,Ri>,E>{
    function f(self,that):DeriveDef<Couple<R,Ri>,E>{
      return switch([self,that]){
        case [Emit(_,nI),Emit(_,nII)]                                 : __.hold(Held.Pause(f.bind(nI,nII)));
        case [Emit(_,nI),Wait(fn)]                                    : __.hold(Held.Pause(f.bind(nI,fn(Push(Noise)))));
        case [Emit(_,nI),Hold(ft)]                                    : __.hold(ft.mod(f.bind(nI)));
        case [Emit(_,nI),Halt(Production(r))]                         : __.hold(Held.Pause(f.bind(nI,__.prod(r))));
        case [Wait(fn),Emit(_,nII)]                                   : __.hold(Held.Pause(f.bind(fn(Push(Noise)),nII)));
        case [Wait(fn),Hold(ft)]                                      : __.hold(ft.mod(f.bind(fn(Push(Noise)))));
        case [Wait(fn),Halt(Production(r))]                           : __.hold(Held.Pause(f.bind(fn(Push(Noise)),__.prod(r))));
        case [Wait(l),Wait(r)]                                        : __.hold(Held.Pause(f.bind(l(Push(Noise)),r(Push(Noise)))));
        case [Hold(l),r]                                              : __.hold(l.mod(f.bind(_,r)));
        
        case [Halt(Production(l)),Halt(Production(r))]                : __.prod(__.couple(l,r));
        case [Halt(Terminated(Exit(e0))),Halt(Terminated(Exit(e1)))]  : __.exit(e0.concat(e1));
        case [Halt(Terminated(Stop)),Halt(Terminated(Exit(e1)))]      : __.exit(e1);
        case [Halt(Terminated(Exit(e))),Halt(Terminated(Stop))]       : __.exit(e);
        case [Halt(Terminated(Stop)),_]                               : __.stop();
        case [Halt(_),Halt(Terminated(Stop))]                         : __.stop();
        case [_,Halt(Terminated(Stop))]                               : __.stop();
        case [_,Halt(Terminated(Exit(e)))]                            : __.exit(e);
        case [Halt(l),r]                                              : __.hold(Held.Pause(f.bind(__.halt(l),r)));
      }
    }
    return Derive.lift(f(self,that));
  }
  // static public function regulate<R,E>(self:DeriveDef<R,E>,fn:Regulate<R,E>):Regulate<R,E>{
  //   return modulate(self,fn);
  // }
  static public function secure<R,E>(self:DeriveDef<R,E>,that:Secure<R,E>):Effect<E>{
    function f(self:DeriveDef<R,E>):EffectDef<E>{
      return switch(self){
        case Emit(o,next)             : __.emit(o,f(next));
        case Wait(tran)               : __.wait(tran.mod(f));
        case Hold(held)               : __.hold(held.mod(f));
        case Halt(Production(r))      : that.provide(r).close();
        case Halt(Terminated(e))      : __.term(e);
      }
    }
    return Effect.lift(f(self));
  }
}