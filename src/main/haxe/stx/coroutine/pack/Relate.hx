package stx.coroutine.pack;

typedef RelateDef<I,R,E> = CoroutineSum<I,Noise,R,E>;

@:using(stx.coroutine.pack.Relate.RelateLift)
@:forward abstract Relate<T,R,E>(RelateDef<T,R,E>) from RelateDef<T,R,E> to RelateDef<T,R,E>{
  static public var _(default,never) = RelateLift;

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
    return lift(__.prod(r));
  }
  @:noUsing static public function fromFun1R<I,O,E>(fn:I->O):Relate<I,O,E>{
    return lift(__.wait(
      Transmission.fromFun1R((x:I) -> __.prod(fn(x)))
    ));
  }
}
class RelateLift{
  static public function toTunnel<I,R,E>(self:Relate<I,R,E>):Tunnel<I,R,E>{
    function rec(self:CoroutineSum<I,Noise,R,E>):Coroutine<I,R,Noise,E>{
      return switch(self){
        case Emit(_,next)               : rec(next);
        case Wait(tran)                 : __.wait(tran.mod(rec));
        case Hold(held)                 : __.hold(held.mod(rec));
        case Halt(Production(out))      : __.emit(out,Halt(Terminated(Stop)));
        case Halt(Terminated(cause))    : __.term(cause);  
      }
    }
    return rec(self);
  }
  /**
    Next time we hit an input request, Stop.
  **/
  static public function derive<I,R,E>(self:RelateDef<I,R,E>):Derive<R,E>{
    function rec(self:RelateDef<I,R,E>):DeriveDef<R,E>{
      final f = rec;
      return switch(self){
        case Emit(o,next) : __.emit(o,f(next));
        case Wait(tran)   : __.stop();
        case Hold(held)   : __.hold(held.mod(f));
        case Halt(r)      : __.halt(r);
      }
    }
    return Derive.lift(rec(self));
  }
}
