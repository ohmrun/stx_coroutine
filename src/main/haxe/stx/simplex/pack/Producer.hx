package stx.simplex.pack;

typedef ProducerDef<R,E> = SimplexDef<Noise,Noise,R,E>;

@:using(stx.simplex.pack.Producer.ProducerLift)
@:forward abstract Producer<R,E>(ProducerDef<R,E>) from ProducerDef<R,E> to ProducerDef<R,E>{
  public function new(self:ProducerDef<R,E>) this = self;
  @:noUsing static public function lift<R,E>(self:ProducerDef<R,E>) return new Producer(self);
  @:from static public function fromSimplex<I,O,R,E>(spx:Simplex<Noise,Noise,R,E>):Producer<R,E>{
    return new Producer(spx);
  }
  @:noUsing static public function fromThunk<R,E>(thk:Thunk<R>):Producer<R,E>{
    return lift(__.lazy(
      () -> __.done(thk())
    ));
  }
  @:to public function toSimplex():Simplex<Noise,Noise,R,E>{
    return this;
  }
}

class ProducerLift{
  
  /*
  static public function toSource<O,R>(cncd:Producer<R,E>):Source<O,R>{
    function recurse(cncd){
      return switch(cncd){
        case Halt(Terminated(cause))  : Halt(Terminated(cause));
        case Halt(Production(ret))    : Halt(Production(ret));
        case Emit(Noise,next)         : 
          trace(next);
          Constructors.kill();
        case Wait(arw)                : Wait(arw.then(recurse));
        case Hold(ft)                 : Hold(ft.map(recurse));
      }
    }
    return recurse(cncd);
  }*/
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
  /*
  static public function drive<R,E>(self:Producer<R,E>,stream:Stream<Noise,Noise>):Future<Return<R,E>>{
    var done  = false;
    var trg   = Future.trigger();
    function recurse(self:Producer<R,E>,step:Step<Noise,Noise>){
        //trace('recurse: $self $step');
        switch(step){
          case Data(_) if (!done) : 
            switch(self){
              case Halt(result)     : 
                done = true;
                trg.trigger(result);
              case Wait(arw)        : 
                stream.next().handle(recurse.bind(arw(Continue(Noise))));
              case Emit(head,tail)  : 
                stream.next().handle(recurse.bind(tail));
              case Hold(ft)         : 
                ft.handle(
                  (self) -> stream.next().handle(recurse.bind(self))
                );
            }
          case Data(_) : 
          case End if (!done) : 
            done = true;
            switch(self){
              case Halt(result) : trg.trigger(result);
              default           : trg.trigger(Terminated(Exit(Errors.driver_ended())));
            }
          case End :
          case Fail(e)          : trg.trigger(Terminated(Exit(stx.Error.fromTinkError(e))));
        }
      }
    stream.next().handle(recurse.bind(self));
    return trg.asFuture();
  }*/
}