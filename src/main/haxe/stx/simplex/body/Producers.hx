package stx.simplex.body;

class Producers{
  @:noUsing static public function fromThunk<R>(thk:Thunk<R>):Producer<R>{
    return Spx.poll(
      () -> Spx.done(thk)
    );
  }
  /*
  static public function toSource<O,R>(cncd:Producer<R>):Source<O,R>{
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
  static public function complete<R>(cncd:Producer<R>,cb:R->Void):Effect{
    function recurse(cncd){
      return switch(cncd){
        case Halt(Terminated(cause))  : Spx.term(cause);
        case Halt(Production(ret))    :
          cb(ret); 
          Spx.stop();
        case Emit(emit)               : Spx.poll(recurse.bind(emit.next));
        case Wait(arw)                : Spx.wait(arw.then(recurse));
        case Hold(ft)                 : Spx.hold(ft.map(recurse));
      } 
    }
    return recurse(cncd);
  }
  /*
  static public function drive<R>(self:Producer<R>,stream:Stream<Noise,Noise>):Future<Return<R>>{
    var done  = false;
    var trg   = Future.trigger();
    function recurse(self:Producer<R>,step:Step<Noise,Noise>){
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
              default           : trg.trigger(Terminated(Early(Errors.driver_ended())));
            }
          case End :
          case Fail(e)          : trg.trigger(Terminated(Early(stx.Error.fromTinkError(e))));
        }
      }
    stream.next().handle(recurse.bind(self));
    return trg.asFuture();
  }*/
}