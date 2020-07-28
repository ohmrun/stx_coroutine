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
      () -> __.done(thk())
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
  
  static public function toSource<O,R,E>(cncd:Derive<R,E>):Source<O,R,E>{
    function recurse(cncd){
      return switch(cncd){
        case Halt(Terminated(cause))  : Halt(Terminated(cause));
        case Halt(Production(ret))    : Halt(Production(ret));
        case Halt(e)                  : Halt(e);
        case Emit(Noise,next)         : __.stop();
        case Wait(arw)                : Wait(arw.mod(recurse));
        case Hold(ft)                 : Hold(ft.mod(recurse));
        case _                        : throw "This is a regression";
      }
    }
    return recurse(cncd);
  }
  static public function complete<R,E>(cncd:Derive<R,E>,cb:R->Void):Effect<E>{
    function recurse(cncd){
      return switch(cncd){
        case Halt(Terminated(cause))  : __.term(cause);
        case Halt(Production(ret))    :
          cb(ret); 
          __.stop();
        case Emit(head,rest)          : rest.mod(recurse);
        case Wait(arw)                : __.wait(arw.mod(recurse));
        case Hold(ft)                 : __.hold(ft.mod(recurse));
      } 
    }
    return Effect.lift(recurse(cncd));
  }
}