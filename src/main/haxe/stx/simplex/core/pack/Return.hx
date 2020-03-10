package stx.simplex.core.pack;

import stx.simplex.core.body.Returns;
import stx.simplex.core.head.data.Return in ReturnT;

abstract Return<T>(ReturnT<T>) from ReturnT<T> to ReturnT<T>{
  public function new(self){
    this = self;
  }
  @:from static public function fromError(e:stx:Error):Return<T<{
    return fromCause(Early(e));
  }
  @:from static public function fromCause<T>(c:Cause):Return<T>{
    return Terminated(c);
  }
  @:from static public function fromT<T>(v:T):Return<T>{
    return Production(v);
  }
  public function map<U>(fn:T->U):Return<U>{
    return Returns.map(this,fn);
  }
  @:to public function toSimplex<I,O>():Simplex<I,O,T>{
    return Halt(this);
  }
}

