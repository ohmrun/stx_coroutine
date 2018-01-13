package stx.simplex.pack;

import stx.simplex.head.Data.Fold in FoldT;

@:forward abstract Fold<T,R>(FoldT<T,R>) from FoldT<T,R> to FoldT<T,R>{
  public inline function new( v : FoldT<T,R> ) {
    this = v;
  }
  /**
   /dev/null
  */
  public static function unit<T,R>():Fold<T,R>{
    return Wait(
      function recurse(ctrl:Control<T>){
        return switch(ctrl){
          case Continue(_)            : Wait(recurse);
          case Discontinue(cause)     : Halt(Terminated(cause)); 
        }
      }
    );
  }
  static public function pure<T,R>(r:R):Fold<T,R>{
    return Halt(Production(r));
  }
}