package stx.simplex.pack;

import stx.simplex.head.Data.Source in SourceT;

abstract Source<O,R>(SourceT<O,R>) from SourceT<O,R> to SourceT<O,R>{
    public function new(self){
        this = self;
    }
}