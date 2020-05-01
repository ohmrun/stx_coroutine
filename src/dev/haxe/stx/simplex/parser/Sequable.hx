package stx.coroutine.pack.Coroutine.parser;

import stx.coroutine.pack.Coroutine.parser.data.Sequable as SequableT;

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