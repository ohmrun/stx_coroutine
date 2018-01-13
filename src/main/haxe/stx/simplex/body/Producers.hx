package stx.simplex.body;

class Producers{
  @:noUsing static public function fromThunk<R>(thk:Thunk<R>):Producer<R>{
    return new Producer(Wait(
      function(_:Control<Noise>){
        return Halt(Production(thk()));
      }
    ));
  }
  static public function toSource<O,R>(cncd:Producer<R>):Source<O,R>{
    function recurse(cncd){
      return switch(cncd){
        case Halt(Terminated(cause))  : Halt(Terminated(cause));
        case Halt(Production(ret))    : Halt(Production(ret));
        case Emit(Noise,next)         : recurse(next);
        case Wait(arw)                : Wait(arw.then(recurse));
        case Hold(ft)                 : Hold(ft.map(recurse));
      }
    }
    return recurse(cncd);
  }
  static public function handle<R>(cncd:Producer<R>,cb:R->Void):Effect{
    function recurse(cncd){
      return switch(cncd){
        case Halt(Terminated(cause))  : Halt(Terminated(cause));
        case Halt(Production(ret))    :
          cb(ret); 
          Halt(Production(Noise));
        case Emit(Noise,next)         : recurse(next);
        case Wait(arw)                : Wait(arw.then(recurse));
        case Hold(ft)                 : Hold(ft.map(recurse));
      } 
    }
    return recurse(cncd);
  }
}