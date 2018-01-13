package stx.simplex.core.body;

import stx.simplex.core.head.Data;
import stx.simplex.core.head.Data.Control in ControlT;


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