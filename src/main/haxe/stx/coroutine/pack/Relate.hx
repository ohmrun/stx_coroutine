package stx.coroutine.pack;

typedef RelateDef<I,R,E> = CoroutineSum<I,Noise,R,E>;

@:forward abstract Relate<T,R,E>(RelateDef<T,R,E>) from RelateDef<T,R,E> to RelateDef<T,R,E>{
  @:noUsing static public function lift<I,R,E>(self:RelateDef<I,R,E>):Relate<I,R,E>{
    return new Relate(self);
  }
  public inline function new(self:RelateDef<T,R,E>) this = self;

  /**
   /dev/null
  */
  @:noUsing public static function unit<T,R,E>():Relate<T,R,E>{
    return lift(__.wait(
      Transmission.fromFun1R(function recurse(v){ return __.wait(Transmission.fromFun1R(recurse)); })
    ));
  }
  @:noUsing static public function pure<T,R,E>(r:R):Relate<T,R,E>{
    return lift(__.done(r));
  }
  @:noUsing static public function fromFunction<I,O,E>(fn:I->O):Relate<I,O,E>{
    return lift(__.wait(
      Transmission.fromFun1R((x:I) -> __.done(fn(x)))
    ));
  }
}
class RelateLift{
  
}