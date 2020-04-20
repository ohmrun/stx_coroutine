class LiftArrowlet{
  static public function asPipe<I,O>(arw:Arrowlet<I,O>):Pipe<I,O>{
      return stx.simplex.body.Pipes.fromArrowlet(arw);
  }