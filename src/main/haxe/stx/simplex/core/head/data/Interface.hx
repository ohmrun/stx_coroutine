package stx.simplex.core.head.data;

import stx.simplex.core.pack.Simplex in SimplexA;
import stx.simplex.core.pack.State in StateA;


interface Interface<I,O,R>{
  public var state(default,null) : StateA<I,O,R>;
  public function mod<I1,O1,R1>(fn:SimplexA<I,O,R>->SimplexA<I1,O1,R1>):SimplexA<I1,O1,R1>;
}