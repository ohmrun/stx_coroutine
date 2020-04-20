package stx.simplex.pack;

typedef FoldDef<I,R,E> = SimplexDef<I,Noise,R,E>;

@:forward abstract Fold<T,R,E>(FoldDef<T,R,E>) from FoldDef<T,R,E> to FoldDef<T,R,E>{
  public inline function new(self:FoldDef<T,R,E>) this = self;

  /**
   /dev/null
  */
  @:noUsing public static function unit<T,R,E>():Fold<T,R,E>{
    return __.wait(
      function recurse(v){ return __.wait(recurse); }
    );
  }
  @:noUsing static public function pure<T,R,E>(r:R):Fold<T,R,E>{
    return __.done(r);
  }
  @:noUsing static public function fromFunction<I,O>(fn:I->O):Fold<I,O>{
    return __.wait(
      (x:I) -> __.done(fn(x))
    );
  }
}
class FoldLift{
  
}