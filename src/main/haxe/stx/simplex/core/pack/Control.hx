package stx.simplex.core.pack;

enum ControlSum<T,E>{
  Push(v:T);
  Quit(v:Cause<E>);
}

@:using(stx.simplex.core.pack.Control.ControlLift)
@:forward abstract Control<T,E>(ControlSum<T,E>) from ControlSum<T,E> to ControlSum<T,E>{
  public function new(self){
    this = self;
  }
  @:from static public function fromCause<T,E>(c:Cause<E>):Control<T,E>{
    return Quit(c);
  }
  @:from static public function fromT<T,E>(v:T):Control<T,E>{
    return Push(v);
  }
  @:noUsing static public function exit<T,E>(c):Control<T,E>{
    return Exit(c);
  }
}
class ControlLift{
  static public function map<T,U,E>(self:Control<T,E>,fn:T->U):Control<U,E>{
    return switch(self){
      case Push(v)      : Push(fn(v));
      case Quit(v)      : Quit(v);
    }
   }
   static public function fold<T,U,E,TT>(self:Control<T,E>,push:T->TT,quit:Cause<E>->TT):TT{
     return switch(self){
       case Push(v) : push(v);
       case Quit(v) : quit(v);
     }
   }
}