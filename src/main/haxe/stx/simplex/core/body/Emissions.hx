package stx.simplex.core.body;

import stx.fn.pack.Unary;
import stx.simplex.core.Package.Simplex in SimplexA;
import stx.simplex.core.pack.Operator in OperatorA;
import stx.simplex.core.pack.Control in ControlA;
import stx.simplex.core.pack.Advice in AdviceA;

class Emissions{
  static public function mod<I,O,R,O1,R1>(e:Emission<I,O,R>,fn:Unary<SimplexA<I,O,R>,SimplexA<I,O1,R1>>):Emission<I,O1,R1>{
    return e.then(fn);
  }
}