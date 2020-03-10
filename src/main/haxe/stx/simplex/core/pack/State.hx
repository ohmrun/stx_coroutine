package stx.simplex.core.pack;

import stx.simplex.core.head.data.Simplex in SimplexT;
import stx.simplex.core.head.data.State in StateT;

abstract State<I,O,R>(StateT<I,O,R>) from StateT<I,O,R> to StateT<I,O,R>{
  public function new(self){
    this = self;
  }
  @:from static public function fromReturn<I,O,R>(r:Return<R>):State<I,O,R>{
    return Halt(r);
  }
  @:from static public function fromCause<I,O,R>(cause:Cause):State<I,O,R>{
    return Halt(Terminated(cause));
  }
  @:from static public function fromEmiting<I,O,R>(e:Emiting<I,O,R>):State<I,O,R>{
    return Emit(e);
  }
  @:from static public function fromEmission<I,O,R>(e:Emission<I,O,R>):State<I,O,R>{
    return Wait(e);
  }
  @:to public function toSimplex():Simplex<I,O,R>{
    return new SimplexT(this);
  }
  @:to public function toInterface():Interface<I,O,R>{
    return new SimplexT(this);
  } 
} 