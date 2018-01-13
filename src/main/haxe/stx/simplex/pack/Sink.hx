package stx.simplex.pack;

import stx.simplex.head.Data.Sink in SinkT;

abstract Sink<I>(SinkT<I>) from SinkT<I> to SinkT<I>{
    public function new(self){
        this = self;
    }
}