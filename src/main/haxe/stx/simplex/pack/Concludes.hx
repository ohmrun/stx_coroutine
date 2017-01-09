package stx.simplex.pack;

import stx.simplex.core.Data;
import stx.simplex.Package;

class Concludes{
  static public function toSource<R>(cncd:Conclude<R>):Source<R>{
    function recurse(cncd){
      return switch(cncd){
        case Halt(Terminated(cause))  : Halt(Terminated(cause));
        case Halt(Production(ret))    : Emit(ret,Halt(Terminated(Finished)));
        case Emit(Noise,next)         : recurse(next);
        case Wait(arw)                : Wait(arw.then(recurse));
        case Held(ft)                 : Held(ft.map(recurse));
      }
    }
    return recurse(cncd);
  }
  static public function apply<R>(cncd:Conclude<R>,cb:R->Void):Effect{
    function recurse(cncd){
      return switch(cncd){
        case Halt(Terminated(cause))  : Halt(Terminated(cause));
        case Halt(Production(ret))    :
          cb(ret); 
          Emit(Noise,Halt(Terminated(Finished)));
        case Emit(Noise,next)         : recurse(next);
        case Wait(arw)                : Wait(arw.then(recurse));
        case Held(ft)                 : Held(ft.map(recurse));
      } 
    }
    return recurse(cncd);
  }
  //static public function conclude<R>(cncd:Conclude<R>,cb:Outcome<R,Error>):
}