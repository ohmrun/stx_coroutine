package stx.simplex.pack.source;

import stx.simplex.core.Data;
using stx.simplex.Package;

class Futures{
  
  static public function lift<T>(src:Source<Future<T>>):Source<T>{
    function recurse(src:Source<Future<T>>):Source<T>{
      return switch(src){
        case Hold(ft)           : Hold(ft.map(recurse));
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
  }
}