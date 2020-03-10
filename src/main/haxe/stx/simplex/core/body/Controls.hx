package stx.simplex.core.body;

import stx.simplex.core.head.Data;
import stx.simplex.core.head.Data.Control in ControlT;


class Controls{
  @:noUsing static public function exit<T>(c):Control<T>{
    return Exit(c);
  }
  @:noUsing static public function map<T,U>(ctl:Control<T>,fn:T->U):Control<U>{
    return switch(ctl){
      case Push(v)      : Push(fn(v));
      case Pull         : Pull;
      case Okay         : Okay;
      case Exit(v)      : Exit(v);
    }
   }
}