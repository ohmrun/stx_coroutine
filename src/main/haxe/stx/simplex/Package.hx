package stx.simplex;

class Package{
    
}
class Iterables{
    /**
     *  Produces a Source from any Iterable.
     *  @param fn - 
     *  @return stx.simplex.head.Data.Unfold<I,O>
     */
    static public function toEmiter<O>(itr:Iterable<O>):Emiter<O>{
        return stx.simplex.body.Emiters.fromIterable(itr);
    }
}
class Thunks{
    static public function toEmiter<O>(thk:Thunk<O>):Emiter<O>{
        return stx.simplex.body.Emiters.fromThunk(thk);
    }
    static public function toProducer<R>(thk:Thunk<R>):Producer<R>{
        return stx.simplex.body.Producers.fromThunk(thk);
    }
}
class Unaries{
    /**
     *  Produces an Unfold from any simple function.
     *  @param fn - 
     *  @return stx.simplex.head.Data.Unfold<I,O>
     */
    static public function toPipe<I,O>(fn:I->O):Pipe<I,O>{
        return stx.simplex.body.Pipes.fromFunction(fn);
    }
    static public function toProduction<I,O,R>(fn:I->R):Emission<I,O,R>{
        return Emission.pure((v:I) -> Halt(Production(fn(v))));
    }
}
class Options{
    static public function toEmiter<O>(opt:Option<O>):Emiter<O>{
        return stx.simplex.body.Emiters.fromOption(opt);
    }
}
class Arrowlets{
    static public function toPipe<I,O>(arw:Arrowlet<I,O>):Pipe<I,O>{
        return stx.simplex.body.Pipes.fromArrowlet(arw);
    }
}



typedef Effect              = stx.simplex.pack.Effect;                  //000
typedef Producer<R>         = stx.simplex.pack.Producer<R>;             //001
typedef Emiter<O>           = stx.simplex.pack.Emiter<O>;               //010
typedef Source<O,R>         = stx.simplex.pack.Source<O,R>;             //011
typedef Sink<I>             = stx.simplex.pack.Sink<I>;                 //100
typedef Fold<I,R>           = stx.simplex.pack.Fold<I,R>;               //101
typedef Pipe<I,O>           = stx.simplex.pack.Pipe<I,O>;               //110
typedef Simplex<I,O,R>      = stx.simplex.core.Package.Simplex<I,O,R>;  //111
