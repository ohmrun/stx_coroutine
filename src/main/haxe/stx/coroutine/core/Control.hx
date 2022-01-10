package stx.coroutine.core;

enum ControlSum<T>{
  Push(v:T);
  Quit(v:Option<Error<Digest>>);
}

@:using(stx.coroutine.core.Control.ControlLift)
@:forward abstract Control<T>(ControlSum<T>) from ControlSum<T> to ControlSum<T>{
  @:noUsing static public function lift<T>(self:ControlSum<T>):Control<T>{
    return new Control(self);
  }
  public function new(self) this = self;

  static public function unit(){
    return lift(Quit(None));
  }
  @:from static public function fromError<T>(c:Error<Digest>):Control<T>{
    return Quit(Some(c));
  }
  @:noUsing static public function quit<T>(c):Control<T>{
    return lift(Quit(c));
  }
  @:from @:noUsing static public function push<T>(v:T):Control<T>{
    return lift(Push(v));
  }
}
class ControlLift{
  static public function map<T,U>(self:Control<T>,fn:T->U):Control<U>{
    return switch(self){
      case Push(v)      : Push(fn(v));
      case Quit(v)      : Quit(v);
    }
   }
   static public function fold<T,U,TT,E>(self:Control<T>,push:T->TT,quit:Error<Digest>->TT,none:Void->TT):TT{
     return switch(self){
       case Push(v)       : push(v);
       case Quit(Some(v)) : quit(v);
       case Quit(None)    : none();
     }
   }
}