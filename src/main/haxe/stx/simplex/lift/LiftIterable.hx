package stx.simplex.lift;
class LiftIterable{
  /**
   *  Produces a Source from any Iterable.
   *  @param fn - 
   *  @return stx.simplex.head.Data.Unfold<I,O>
   */
  static public function asEmiter<O>(itr:Iterable<O>):Emiter<O>{
      return stx.simplex.body.Emiters.fromIterable(itr);
  }
}