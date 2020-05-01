package stx.coroutine.pack;

import stx.coroutine.core.Data.Sampler in SamplerT;

abstract Sampler<I,O,R>(SamplerT<I,O,R>) from SamplerT<I,O,R> to SamplerT<I,O,R>{
  public function new(self){
    this = self;
  }
}