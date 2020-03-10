package stx.simplex.core.head.data;

import stx.simplex.core.pack.Emiting in EmitingA;
import stx.simplex.core.pack.Simplex in SimplexA;

class Emiting<I,O,R>{
  public var next(default,null): SimplexA<I,O,R>;
  public var data(default,null): O;

  public function new(next:SimplexA<I,O,R>,data:O){
    this.next = next;
    this.data = data;
  }
  public function cons(v:O):SimplexA<I,O,R>{
    return null;
  }
  public function mod<I1,R1>(fn:SimplexA<I,O,R>->SimplexA<I1,O,R1>):EmitingA<I1,O,R1>{
    return new Emiting(fn(this.next),this.data);
  }
}