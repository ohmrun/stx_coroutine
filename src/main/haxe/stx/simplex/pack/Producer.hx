package stx.simplex.pack;

import stx.simplex.head.Data.Producer in ProducerT;

import stx.simplex.body.Producers;

@:forward abstract Producer<R>(ProducerT<R>) from ProducerT<R> to ProducerT<R>{
  @:from static public function fromSimplex<I,O,R>(spx:Simplex<Noise,Noise,R>):Producer<R>{
    return new Producer(spx);
  }
  @:from static public function fromThunk<T>(thk:Void->T):Producer<T>{
    return Producers.fromThunk(thk);
  }
  public function new(self:ProducerT<R>){
    this = self;
  } 
  /*
  @:to public function toSource<O>():Source<O,R>{
    return Producers.toSource(this);
  }*/
  public function complete(fn:R->Void):Effect{
    return Producers.complete(this,fn);
  }
  // public function drive(stream:Stream<Noise,Noise>):Future<Return<R>>{
  //   return Producers.drive(this,stream);
  // }
  public function tap(fn):Producer<R>{
    return this.tap(fn);
  }
  public function tapO(fn):Producer<R>{
    return this.tapO(fn);
  }
}
