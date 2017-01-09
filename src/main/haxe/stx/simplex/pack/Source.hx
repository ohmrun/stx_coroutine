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
  @:to public function toPipe():Pipe<Noise,O>{
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
  public function shipment():Shipment<O>{
    return new Shipment(Simplexs.map(this,Val)); 
  }
  public function new(self:SourceT<O>){
    this = self;
  }
  /*
  @:from static public function fromSourceFutures<T>(source:Source<Future<T>>):Source<T>{
    return stx.simplex.pack.source.Futures.lift(source);
  }*/
  @:from static public function fromIterable<T>(arr:Iterable<T>):Source<T>{
    function recurse(it:Iterator<T>,ctl:Control<Noise>):Source<T>{
      return switch(ctl){
        case Continue(Noise) :
          return it.hasNext()
            ? {
                var out = it.next();
                //trace('emit $out');
                Emit(out,Wait(recurse.bind(it)));
              }
            : 
              {
                //trace("done");
                Halt(Production(Noise));
              }
        case Discontinue(cause) : Halt(Terminated(cause));         
      }
    }
    return new Source(Wait(
      function(ctl:Control<Noise>){
        var itr = arr.iterator();
        return recurse(itr,ctl);
      }
    ));
  }
  public function merge(that:Source<O>):Source<O>{
    return new Source(this.mergeWith(
      that,
      function(x,y){ return y; }
    ));
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
  public function filter(fn:O->Bool):Source<O>{
    return switch(this){
      case Emit(head,tail) : 
        if(fn(head)){
          Emit(head,tail.filter(fn));
        }else{
          tail.filter(fn);
        }
      case Wait(fn)        : Wait(fn);
      case Held(ft)        : Held(ft);
      case Halt(t)         : Halt(t);
    }
  }
  public function mapFilter<U>(fn:O->Option<U>):Source<U>{
    return Sources.mapFilter(this,fn);
  }
  public function map<U>(fn:O->U):Source<U>{
    return new Source(Simplexs.map(this,fn));
  }
  public function foldLeft<U>(fn:O->U->U,memo:U):Conclude<U>{
    return Sources.foldLeft(this,fn,memo);
  }
  public function pipeTo(fn:O->Void):Future<Cause>{
    return Sources.pipeTo(this,fn);
  }
}
