package stx.simplex.pack.source;

using stx.Pointwise;

import stx.Chunk;

import stx.simplex.core.Data;
import stx.simplex.core.data.Simplex in SimplexT;
using stx.simplex.Package;

typedef PartitionT<T> = stx.simplex.core.data.Source<Chunk<T>>;

@:forward abstract Partition<T>(PartitionT<T>) from PartitionT<T> to PartitionT<T>{
  @:to public function toSimplex():Simplex<Noise,Chunk<T>,Noise>{
    return this.toSimplex();
  }
  @:from static public function fromSimplex<T>(spx:Simplex<Noise,Chunk<T>,Noise>):Partition<T>{
    return new Partition(spx);
  }
  @:from static public function fromSimplexT<T>(spx:SimplexT<Noise,Chunk<T>,Noise>):Partition<T>{
    return new Partition(spx);
  }
  public function new(self){
    this = self;
  }
  public function slice(fn:T->Bool):Partition<T>{
    return Partitions.slice(this,fn);
  }
  @:to public function toStream(){
    return new SourceStream(new Source(this));    
  }
  public function chunk():Partition<T>{
    return slice(
      function(_){
        return true;
      }
    );
  }
  public function derive<U>(fn:T->Source<U>):Partition<U>{
    return new Partition(Sources.flatMap(
      this,
      function(x:Chunk<T>):Source<Chunk<U>>{
        return switch(x){
          case Val(v) : fn(v).map(Val);
          case End(e) : [End(e)];
          case Nil    : [Nil];
        }
      }
    ));
  }
}