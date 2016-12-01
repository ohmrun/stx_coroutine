package stx.simplex.pack;

import tink.CoreApi;

using stx.Pointwise;

import stx.Chunk;

import tink.streams.StreamStep;
import tink.streams.Stream;
import tink.streams.Accumulator;


import stx.simplex.core.Data;
using stx.simplex.Package;

import stx.simplex.pack.source.SourceStream;

import stx.simplex.core.Data.Source in SourceT;

abstract Source<O>(SourceT<O>) from SourceT<O> to SourceT<O>{
  @:to public function toSimplex():Simplex<Noise,O,Noise>{
    return this;
  }
  static public function unit<T>():Source<T>{
    return new Source(
      Wait(
        function(_:Control<Noise>){
          return Halt(Production(Noise));
        }
      )
    );
  }
  public function partition():Partition<O>{
    return new Partition(Simplexs.map(this,Val)); 
  }
  public function new(self:SourceT<O>){
    this = self;
  }
  @:from static public function fromIterable<T>(arr:Iterable<T>):Source<T>{
    function recurse(it:Iterator<T>,ctl:Control<Noise>):Source<T>{
      return switch(ctl){
        case Continue(Noise) :
          return it.hasNext()
            ?
              Emit(it.next(),Wait(recurse.bind(it)))
            :
              Halt(Terminated(Finished));
        case Discontinue(cause) : Halt(Terminated(cause));         
      }
    }
    return new Source(Wait(
      recurse.bind(arr.iterator())
    ));
  }
  public function merge(that:Source<O>):Source<O>{
    return this.mergeWith(
      that,
      function(x,y){ return y; }
    );
  }
  @:to public function toStream():Stream<O>{
    return new SourceStream(this);
  }
  public function emit(o:O):Source<O>{
    return switch(this){
      case Halt(Terminated(Finished)) | Halt(Production(Noise))  :
        Emit(o,this);
      case Emit(head,tail)  :
        var op : Source<O> = tail; 
        Emit(head,op.emit(o));
      case Wait(fn)         :
        var op : Source<O> = fn(Noise);  
        op.emit(o);
      case Held(ft)         :
        var later : FutureTrigger<Source<O>> = Future.trigger();
        ft.handle(
          function(next:Source<O>){
            var op = emit(o);
            later.trigger(op); 
          }
        );  
        Held(later.asFuture());
      default : Halt(Noise);
    };
  }
  public function map<U>(fn:O->U):Source<U>{
    return Simplexs.map(this,fn);
  }
  public function fold<U>(fn:T->U->U,memo:U):Conclude<U>{
    return Sources.fold(this,fn,memo);
  }
}
