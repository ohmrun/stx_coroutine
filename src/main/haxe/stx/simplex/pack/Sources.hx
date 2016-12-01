package stx.simplex.pack;

using stx.Pointwise;

import stx.simplex.core.Data;
using stx.simplex.Package;

class Sources{
  static public function flatMap<T,U>(source:Source<T>,fn:T->Source<U>):Source<U>{
    function recurse(v:Source<T>):Source<U>{
      return switch(v){
        case Emit(head,tail) : 
          var s0 : Source<U> = fn(head);
          s0.merge(flatMap(tail,fn));
        case Halt(e)    : Halt(e);
        case Held(ft)   : Held(cast ft.map(recurse));
        case Wait(arw)  : flatMap(arw(Noise),fn);
      }
    }
    return recurse(source);
  }
  static public function fold<T,U>(source:Source<T>,fn:T->U->U,memo:U):Conclude<U>{
    return switch(source){
      case Emit(head,tail)                      : fold(tail,fn,fn(head,memo));
      case Halt(Production(Noise))              : Halt(Production(memo));
      case Halt(Terminated(Finished))           : Halt(Production(memo));
      case Halt(Terminated(cause))              : Halt(Terminated(cause));
      case Wait(arw)                            : Wait(arw.then(fold.bind(_,fn,memo)));
      case Held(ft)                             : Held(ft.map(fold.bind(_,fn,memo)));
    }
  }
}