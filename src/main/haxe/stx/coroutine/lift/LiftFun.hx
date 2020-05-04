package stx.coroutine.lift;

class LiftUnary{
  /**
   *  Produces an Unfold from any simple function.
   *  @param fn - 
   *  @return stx.coroutine.head.Data.Unfold<I,O>
   */
  static public function asTunnel<I,O>(fn:I->O):Tunnel<I,O>{
      return stx.coroutine.body.Tunnels.fromFunction(fn);
  }
  static public function asProduction<I,O,R,E>(fn:I->R):Emission<I,O,R,E>{
      return Emission.pure((v:I) -> Halt(Production(fn(v))));
  }
  static public function asRelate<I,O>(fn:I->O):Relate<I,O>{
    return Relates.fromFunction(fn);
  }
}