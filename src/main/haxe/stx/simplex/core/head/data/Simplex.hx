package stx.simplex.core.head.data;


import stx.simplex.core.pack.Emission in EmissionA;
import stx.simplex.core.pack.State in StateA;
import stx.simplex.core.pack.Simplex in SimplexA;

import stx.simplex.core.head.Data;

class Simplex<I,O,R> implements Interface<I,O,R>{
  public var state(default,null) : StateA<I,O,R>;
  public function new(state:StateA<I,O,R>){
    this.state = state;
  }
  public function mod<I1,O1,R1>(fn:SimplexA<I,O,R>->SimplexA<I1,O1,R1>):SimplexA<I1,O1,R1>{
    return fn(this);
  }
  public function toString(){
    return stx.simplex.core.body.Simplexs.toString(this);
  }
}
