package stx.simplex.pack;

import stx.simplex.head.Data.Producer in ProducerT;

import stx.simplex.body.Producers;

@:forward abstract Producer<R>(ProducerT<R>) from ProducerT<R> to ProducerT<R>{
  @:from static public function fromThunk<T>(thk:Void->T):Producer<T>{
    return Producers.fromThunk(thk);
  }
  public function new(self:ProducerT<R>){
    this = self;
  } 
  @:to public function toSource<O>():Source<O,R>{
    return Producers.toSource(this);
  }
  public function handle(fn:R->Void):Effect{
    return Producers.handle(this,fn);
  }
  /*
  public function drive(stream:Stream<Noise>):Future<Return<R>>{
    var trg   = Future.trigger();
    var self = this;
    stream.next(
      function(step){
        switch(step){
          case 
        }
      }
    );
    stream.forEach(
      function recurse(_:Noise){ 
        return switch(self){
          case Halt(result)     : trg.trigger(result); false;
          case Wait(arw)        : self = arw(Continue(Noise)); true;
          case Emit(head,tail)  : self = tail; true;
          case Hold(ft)         : ft
        }
      }
    );
    return trg.asFuture();
  }*/
}
