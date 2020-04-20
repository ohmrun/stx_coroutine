package stx.simplex.pack;

typedef SinkDef<I> = SimplexDef<I,Noise,Noise>;
import stx.simplex.body.Sinks;

@:forward abstract Sink<I>(SinkT<I>) from SinkT<I> to SinkT<I>{
    public function new(self){
        this = self;
    }
    static public function handler<O>(fn:O->Void):Sink<O>{
        return Wait(
            function recurse (ctl:Control<O>):Sink<O>{
                return ctl.lift(
                    (o) -> {
                        fn(o);         
                        return Wait(recurse);
                    }
                );
            }
        );
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