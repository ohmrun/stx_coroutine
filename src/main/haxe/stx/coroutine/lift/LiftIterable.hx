package stx.coroutine.lift;
class LiftIterable{
  /**
   *  Produces a Source from any Iterable.
   *  @param fn - 
   *  @return stx.coroutine.head.Data.Unfold<I,O>
   */
  static public function asEmiter<O,E>(itr:Iterator<O>):Emiter<O,E>{
      return Emiter.fromIterator(itr);
  }
}