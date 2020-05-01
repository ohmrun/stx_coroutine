package stx.coroutine.pack.Coroutine.parser;

import stx.coroutine.pack.Coroutine.parser.data.Produce as ProduceT;

abstract Produce<I,O>(ProduceT<I,O>) from ProduceT<I,O> to ProduceT<I,O>{
  public function new(self){
    this = self;
  }
  static public function zero<I,O>(){
    return Accept(null,null);
  }
  static public function pure<I,O>(i:I){
    return Accept(i,null);
  }
  static public function create<I,O>(i:I,o:O):Produce<I,O>{
    return Accept(i,o);
  }
  public function map<I,O,R>(fn:O->R):Produce<I,R>{
    return Produces.map(this,fn);
  }
}
class Produces{
  //static public function fold<I,O,Z>(pd:Produce<I,O>,acc:I->Z,)
  static public function map<I,O,R>(pd:Produce<I,O>,fn:O->R):Produce<I,R>{
    return switch(pd){
      case Accept(i, o) : Accept(i,fn(o));
      case Reject(err)  : Reject(err);
      case Expect(exp)  : Expect(exp); 
    }
  }
}
