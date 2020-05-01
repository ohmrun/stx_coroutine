package stx.coroutine.pack.source;

using stx.Pointwise;

import stx.Chunk;

import stx.coroutine.core.Data;
import stx.coroutine.core.data.Coroutine in CoroutineT;
using stx.coroutine.Package;

typedef ShipmentT<T> = stx.coroutine.core.data.Source<Chunk<T>>;

@:forward abstract Shipment<T>(ShipmentT<T>) from ShipmentT<T> to ShipmentT<T>{
  @:to public function toCoroutine():Coroutine<Noise,Chunk<T>,Noise>{
    return this;
  }
  @:to public function toSource():Source<Chunk<T>>{
    return this;
  }
  @:from static public function fromCoroutine<T>(spx:Coroutine<Noise,Chunk<T>,Noise>):Shipment<T>{
    return new Shipment(spx);
  }
  @:from static public function fromCoroutineT<T>(spx:CoroutineT<Noise,Chunk<T>,Noise>):Shipment<T>{
    return new Shipment(spx);
  }
  public function new(self){
    this = self;
  }
  public function slice(fn:T->Bool):Shipment<T>{
    return Shipments.slice(this,fn);
  }
  @:to public function toStream(){
    return new SourceStream(new Source(this));    
  }
  public function materialize():Source<Chunk<Chunk<T>>>{
    var out : Source<Chunk<Chunk<T>>> = new Source(this.map(Val));
        out = out.emit(Nil);
    return out;
  }
  public function chunk():Shipment<T>{
    return slice(
      function(_){
        trace(_);
        return true;
      }
    );
  }
}
