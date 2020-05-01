package stx.coroutine.pack;

import stx.Pointwise.Cell;

@:forward abstract Reactor<I,O,R>(Cell<Coroutine<I,O,R>>) from Cell<Coroutine<I,O,R>> to Cell<Coroutine<I,O,R>>{
    function new(self){
        this = self;
    }
    /*
    @:from static public function fromCoroutine(spx:Coroutine<I,O,R>):Reactor<I,O,R>{
        var react = new Reactor(Hold())
    }*/
    public function feed(emit:Emiter<I>):Void{
        this.unbox().value = this.value.feed(emit);
    }
}