package stx.simplex.coore.pack;

import stx.simplex.core.Data.Return in ReturnT;

abstract Return<T>(ReturnT<T>) from ReturnT<T> to ReturnT<T>{
  public function new(self){
    this = self;
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
}

