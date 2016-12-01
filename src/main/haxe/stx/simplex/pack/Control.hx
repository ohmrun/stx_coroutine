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
}
class Controls{
  @:noUsing static public function lift<T,O,R>(ctl:Control<T>,fn:T->Simplex<T,O,R>):Simplex<T,O,R>{
    return switch(ctl){
      case Discontinue(cause) : Halt(Terminated(cause));
      case Continue(i)        : fn(i);
    }
  }
  static public function map<T,U>(ctl:Control<T>,fn:T->U):Control<U>{
    return switch(ctl){
      case Continue(v)      : Continue(fn(v));
      case Discontinue(v)   : Discontinue(v);
    }
  }
  static public function each<T>(ctl:Control<T>,fn:T->Void):Control<T>{
    return map(ctl,
      function(x){
        fn(x);
        return x;
      }
    );
  }
}