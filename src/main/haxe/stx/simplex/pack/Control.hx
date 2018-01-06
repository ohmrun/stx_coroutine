package stx.simplex.pack;

import stx.simplex.core.Data;
import stx.simplex.core.Data.Control in ControlT;

import stx.simplex.Package;

abstract Control<T>(ControlT<T>) from ControlT<T> to ControlT<T>{
  public function new(self){
    this = self;
  }
  @:from static public function fromCause<T>(c:Cause):Control<T>{
    return Discontinue(c);
  }
  @:from static public function fromT<T>(v:T):Control<T>{
    return Continue(v);
  }
  public function map<U>(fn:T->U):Control<U>{
    return Controls.map(this,fn);
  }
  public function each<U>(fn:T->Void):Control<T>{
    return Controls.each(this,fn);
  }
  @:to public function toReturn():Return<T>{
    return switch(this){
      case Continue(v)      : Production(v);
      case Discontinue(v)   : Terminated(v);
    }
  }
  public function lift<O,R>(fn:T->Simplex<T,O,R>):Simplex<T,O,R>{
    return Controls.lift(this,fn);
  }
  static public function cont<T,O,R>(fn:T->Simplex<T,O,R>):Control<T> -> Simplex<T,O,R>{
    return Controls.lift.bind(_,fn);
  }
}