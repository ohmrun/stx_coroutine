package stx.simplex.pack;

typedef FoldDef<I,R,E> = SimplexSum<I,Noise,R,E>;

@:forward abstract Fold<T,R,E>(FoldDef<T,R,E>) from FoldDef<T,R,E> to FoldDef<T,R,E>{
  @:noUsing static public function lift<I,R,E>(self:FoldDef<I,R,E>):Fold<I,R,E>{
    return new Fold(self);
  }
  public inline function new(self:FoldDef<T,R,E>) this = self;

  /**
   /dev/null
  */
  @:noUsing public static function unit<T,R,E>():Fold<T,R,E>{
    return lift(__.wait(
      Transmission.fromFun1R(function recurse(v){ return __.wait(Transmission.fromFun1R(recurse)); })
    ));
  }
  @:noUsing static public function pure<T,R,E>(r:R):Fold<T,R,E>{
    return lift(__.done(r));
  }
  @:noUsing static public function fromFunction<I,O,E>(fn:I->O):Fold<I,O,E>{
    return lift(__.wait(
      Transmission.fromFun1R((x:I) -> __.done(fn(x)))
    ));
  }
}
class FoldLift{
  
}