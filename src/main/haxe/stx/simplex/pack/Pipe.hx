package stx.simplex.pack;

import stx.simplex.core.data.Pipe in PipeT;

abstract Pipe<I,O>(PipeT<I,O>) from PipeT<I,O> to PipeT<I,O>{
  public function new(self){
    this = self;
  }
}