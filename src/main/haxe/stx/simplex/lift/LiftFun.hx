package stx.simplex.lift;

class LiftUnary{
  /**
   *  Produces an Unfold from any simple function.
   *  @param fn - 
   *  @return stx.simplex.head.Data.Unfold<I,O>
   */
  static public function asPipe<I,O>(fn:I->O):Pipe<I,O>{
      return stx.simplex.body.Pipes.fromFunction(fn);
  }
  static public function asProduction<I,O,R,E>(fn:I->R):Emission<I,O,R,E>{
      return Emission.pure((v:I) -> Halt(Production(fn(v))));
  }
  static public function asFold<I,O>(fn:I->O):Fold<I,O>{
    return Folds.fromFunction(fn);
  }
}