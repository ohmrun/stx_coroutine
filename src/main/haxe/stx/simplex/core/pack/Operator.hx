package stx.simplex.core.pack;

import stx.simplex.core.head.Data.Operator in OperatorT;

@:callable abstract Operator<T>(OperatorT<T>) from OperatorT<T>{
  public function new(self){
    this = self;
  }
  static public function unit<T>():Operator<T>{
    return function(fn:Advice->Control<T>){
      return fn(Pick);
    }
  }
  static public function pusher<T>(v:T):Operator<T>{
    return function(fn){
      return Push(v);
    }
  }
  public function reply(){
    return this(Op.okay());
  }
}