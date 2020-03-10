package stx.simplex.pack;

import stx.simplex.head.Data.Sink in SinkT;
import stx.simplex.body.Sinks;

@:forward abstract Sink<I>(SinkT<I>) from SinkT<I> to SinkT<I>{
    public function new(self){
        this = self;
    }
    static public function handler<I>(fn:I->Void):Sink<I>{
        return Sinks.handler(fn);
    }
    static public function nowhere(){
        return handler((x)-> {});
    }
    public function provide(v:I):Sink<I>{
        return this.provide(v);
    }
    @:from static public function fromHandler<I>(fn:I->Void):Sink<I>{
        return handler(fn);
    } 
}