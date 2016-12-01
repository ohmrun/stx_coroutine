package stx.simplex.pack.Simplex.producer;

import stx.simplex.pack.core.Data.Return;
import stx.simplex.pack.core.Data.Cause;
import stx.simplex.pack.core.Data.Control;

import tink.core.Noise;


import stx.simplex.pack.core.Data.Simplex;

import stx.simplex.pack.core.Data.Source in SourceT;

import tink.streams.StreamStep;
import tink.streams.Stream;
import haxe.ds.Option;
import stx.simplex.pack.core.Data.Producer in ProducerT;

typedef YieldT<O> = ProducerT<O,Noise>;

@:forward abstract Yield<O>(ProducerT<O,Noise>){
  public function new(self){
    this = self;
  }
  @:from static public function fromStream<T>(str:Stream<T>):Yield<T>{
    return new Yield(Wait(
      function recurse(_:Control<Noise>){
        return Held(
          str.next().map(
            function(x){
              return switch(x){
                case End      : Halt(Terminated(End));
                case Fail(e)  : Halt(Terminated(Early(stx.Error.fromTinkError(e))));
                case Data(v)  : Emit(v,Wait(recurse));
              }              
            }
          )
        );
      }
    ));
  }
}