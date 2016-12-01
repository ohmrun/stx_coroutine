package stx.simplex.pack;

import tink.CoreApi;

import stx.simplex.core.Data;
import stx.simplex.Package;

import stx.simplex.core.data.Consumer in ConsumerT;

@:forward abstract Consumer<T,R>(ConsumerT<T,R>) from ConsumerT<T,R> to ConsumerT<T,R>{
  public inline function new( v : ConsumerT<T,R> ) {
    this = v;
  }
  /**
   /dev/null
  */
  public static function zero<T,R>():Consumer<T,R>{
    return Wait(
      function recurse(ctrl:Control<T>){
        return switch(ctrl){
          case Continue(_)            : Wait(recurse);
          case Discontinue(cause)     : Halt(Terminated(cause)); 
        }
      }
    );
  }
  static public function pure<T,R>(r:R):Consumer<T,R>{
    return Halt(r);
  }
}