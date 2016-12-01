package stx.simplex.pack.Simplex.parser;

import stx.simplex.pack.Simplex.parser.data.Sequable as SequableT;

abstract Sequable<T>(SequableT<T>) from SequableT<T> to SequableT<T>{
  public function new(self){
    this = self;
  }
  @:from static public function fromArray<T>(arr:Array<T>):Sequable<T>{
    return {
      seq : function(){ return (arr:Seq<T>); }
    }
  } 
}