package stx.simplex.pack;

import stx.Pointwise.Cell;

@:forward abstract Reactor<I,O,R>(Cell<Simplex<I,O,R>>) from Cell<Simplex<I,O,R>> to Cell<Simplex<I,O,R>>{
    function new(self){
        this = self;
    }
    /*
    @:from static public function fromSimplex(spx:Simplex<I,O,R>):Reactor<I,O,R>{
        var react = new Reactor(Hold())
    }*/
    public function feed(emit:Emiter<I>):Void{
        this.unbox().value = this.value.feed(emit);
    }
}