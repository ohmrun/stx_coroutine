package stx.simplex.core.pack;

import stx.simplex.core.head.Data.Held in HeldT;

@:forward abstract Held<I,O,R>(HeldT<I,O,R>) from HeldT<I,O,R>{
    @:from static public function fromFutureSimplex<I,O,R>(spx:Future<Simplex<I, O, R>>):Held<I,O,R>{
        return new Held(spx);
    }
    public function new(self){
        this = self;
    }
    static public function trigger<I,O,R>():HeldTrigger<I,O,R>{
        return Future.trigger();
    }
    public function map<I1,O1,R1>(fn):Held<I1,O1,R1>{
        return this.map(fn);
    }
    public function unwrap():Future<Simplex<I,O,R>>{
        return this;
    }
}