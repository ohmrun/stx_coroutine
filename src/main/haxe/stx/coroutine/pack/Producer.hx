package stx.coroutine.pack;

typedef ProducerDef<R,E> = CoroutineSum<Noise,Noise,R,E>;

@:using(stx.coroutine.pack.Producer.ProducerLift)
@:forward abstract Producer<R,E>(ProducerDef<R,E>) from ProducerDef<R,E> to ProducerDef<R,E>{
  public function new(self:ProducerDef<R,E>) this = self;
  @:noUsing static public function lift<R,E>(self:ProducerDef<R,E>) return new Producer(self);
  @:from static public function fromCoroutine<I,O,R,E>(spx:Coroutine<Noise,Noise,R,E>):Producer<R,E>{
    return new Producer(spx);
  }
  @:noUsing static public function fromThunk<R,E>(thk:Thunk<R>):Producer<R,E>{
    return lift(__.lazy(
      () -> __.done(thk())
    ));
  }
  @:to public function toCoroutine():Coroutine<Noise,Noise,R,E>{
    return this;
  }
}

class ProducerLift{
  
  static public function toSource<O,R,E>(cncd:Producer<R,E>):Source<O,R,E>{
    function recurse(cncd){
      return switch(cncd){
        case Halt(Terminated(cause))  : Halt(Terminated(cause));
        case Halt(Production(ret))    : Halt(Production(ret));
        case Emit(Noise,next)         : __.stop();
        case Wait(arw)                : Wait(arw.mod(recurse));
        case Hold(ft)                 : Hold(ft.mod(recurse));
      }
    }
    return recurse(cncd);
  }
  static public function complete<R,E>(cncd:Producer<R,E>,cb:R->Void):Effect<E>{
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