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
    return Spx.wait(
      function recurse(v){ return Spx.wait(recurse); }
    );
  }
  static public function pure<T,R>(r:R):Fold<T,R>{
    return Spx.done(r);
  }
}