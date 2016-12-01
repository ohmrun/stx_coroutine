package stx.simplex.pack;

import stx.simplex.core.Data.Producer in ProducerT;

import stx.simplex.Package;

@:forward abstract Producer<O,R>(ProducerT<O,R>) from ProducerT<O,R> to ProducerT<O,R>{
  @:from static public function fromThunk<T>(thunk:Void->T):Producer<T,Noise>{
    var out = Simplexs.generator(thunk);
    return new Producer(out);
  }
  public function new(self){
    this = self;
  } 
}
class Producers{
  
}