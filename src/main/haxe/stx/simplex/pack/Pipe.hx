package stx.simplex.pack;

import stx.simplex.head.Data.Pipe in PipeT;
import stx.simplex.body.Pipes;

abstract Pipe<I,O>(PipeT<I,O>) from PipeT<I,O> to PipeT<I,O>{
  public function new(self){
    this = self;
  }
  @:from static public function fromFunction<I,O>(fn:I->O):Pipe<I,O>{
    return Pipes.fromFunction(fn);
  }
  @:from static public function fromArrowlet<I,O>(fn:Arrowlet<I,O>):Pipe<I,O>{
    return Pipes.fromArrowlet(fn);
  }
  public function flatMap<O2>(fn:O->Pipe<I,O2>):Pipe<I,O2>{
    return Pipes.flatMap(this,fn);
  }
  public function append(that):Pipe<I,O>{
    return Pipes.append(this,that);
  }
}