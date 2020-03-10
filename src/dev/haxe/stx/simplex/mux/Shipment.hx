package stx.simplex.pack.source;

using stx.Pointwise;

import stx.Chunk;

import stx.simplex.core.Data;
import stx.simplex.core.data.Simplex in SimplexT;
using stx.simplex.Package;

typedef ShipmentT<T> = stx.simplex.core.data.Source<Chunk<T>>;

@:forward abstract Shipment<T>(ShipmentT<T>) from ShipmentT<T> to ShipmentT<T>{
  @:to public function toSimplex():Simplex<Noise,Chunk<T>,Noise>{
    return this;
  }
  @:to public function toSource():Source<Chunk<T>>{
    return this;
  }
  @:from static public function fromSimplex<T>(spx:Simplex<Noise,Chunk<T>,Noise>):Shipment<T>{
    return new Shipment(spx);
  }
  @:from static public function fromSimplexT<T>(spx:SimplexT<Noise,Chunk<T>,Noise>):Shipment<T>{
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
