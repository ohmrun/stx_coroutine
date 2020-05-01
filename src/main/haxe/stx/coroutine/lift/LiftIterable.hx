package stx.coroutine.lift;
class LiftIterable{
  /**
   *  Produces a Source from any Iterable.
   *  @param fn - 
   *  @return stx.coroutine.head.Data.Unfold<I,O>
   */
  static public function asEmiter<O>(itr:Iterable<O>):Emiter<O>{
      return stx.coroutine.body.Emiters.fromIterable(itr);
  }
}