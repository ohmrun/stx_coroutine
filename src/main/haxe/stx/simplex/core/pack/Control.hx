package stx.simplex.core.pack;

import stx.simplex.core.head.Data.Control in ControlT;
import stx.simplex.core.body.Controls;

@:forward abstract Control<T>(ControlT<T>) from ControlT<T> to ControlT<T>{
  public function new(self){
    this = self;
  }
  @:from static public function fromCause<T>(c:Cause):Control<T>{
    return Exit(c);
  }
  @:from static public function fromT<T>(v:T):Control<T>{
    return Push(v);
  }
  public function map<U>(fn:T->U):Control<U>{
    return Controls.map(this,fn);
  }
}