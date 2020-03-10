package stx.simplex.core.pack;

import stx.simplex.core.head.data.Op in OpT;

@:callable abstract Op<T>(OpT<T>) from OpT<T> to OpT<T>{
  public function new(self){
    this = self;
  }
  static public function pull<T>():Op<T>{
    return orExit((_) -> Pull);
  }
  static public function push<T>(v:T):Op<T>{
    return orExit((_) -> Push(v));
  } 
  static public function bang():Op<Noise>{
    return orExit((_) -> Push(Noise));
  }
  static public function okay<T>():Op<T>{
    return orExit((_) -> Okay);
  } 
  static public function orExit<T>(op:Op<T>):Op<T>{
    return (advice) -> switch(advice){
      case Hung(cause) : Exit(cause);
      default : op(advice);
    }
  }
  public function map<U>(fn:T->U):Op<U>{
    return new Op(this.fn().then((ctl) -> ctl.map(fn)));
  }
}