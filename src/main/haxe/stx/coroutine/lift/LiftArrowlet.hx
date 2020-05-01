class LiftArrowlet{
  static public function asPipe<I,O>(arw:Arrowlet<I,O>):Pipe<I,O>{
      return stx.coroutine.body.Pipes.fromArrowlet(arw);
  }