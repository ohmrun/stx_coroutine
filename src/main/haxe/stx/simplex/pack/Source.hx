package stx.simplex.pack;

import stx.simplex.body.Sources;

import stx.simplex.head.Data.Source in SourceT;

@:forward abstract Source<O,R>(SourceT<O,R>) from SourceT<O,R> to SourceT<O,R>{
    public function new(self){
        this = self;
    }
    public function swallow(fn:R->Void):Emiter<O>{
        return Sources.swallow(this,fn);
    }
}