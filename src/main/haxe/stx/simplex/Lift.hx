package stx.simplex;

import haxe.PosInfos;

typedef Errors = stx.simplex.core.body.Errors;


class Lift{
  static public function upcast<I,O,R>(spx:stx.simplex.core.head.data.Simplex<I,O,R>):Simplex<I,O,R>{
    return spx;
  }
  static public function asEmiter<O>(spx:Simplex<Noise,O,Noise>):Emiter<O>{
    return new Emiter(spx);
  }
  static public function asPipe<I,O>(spx:Simplex<I,O,Noise>):Pipe<I,O>{
    return new Pipe(spx);
  }
}
class LiftIterable{
    /**
     *  Produces a Source from any Iterable.
     *  @param fn - 
     *  @return stx.simplex.head.Data.Unfold<I,O>
     */
    static public function asEmiter<O>(itr:Iterable<O>):Emiter<O>{
        return stx.simplex.body.Emiters.fromIterable(itr);
    }
}
class LiftThunk{
    static public function toEmiter<O>(thk:Thunk<O>):Emiter<O>{
        return stx.simplex.body.Emiters.fromThunk(thk);
    }
    static public function toProducer<R>(thk:Thunk<R>):Producer<R>{
        return stx.simplex.body.Producers.fromThunk(thk);
    }
}
class LiftUnary{
    /**
     *  Produces an Unfold from any simple function.
     *  @param fn - 
     *  @return stx.simplex.head.Data.Unfold<I,O>
     */
    static public function asPipe<I,O>(fn:I->O):Pipe<I,O>{
        return stx.simplex.body.Pipes.fromFunction(fn);
    }
    static public function asProduction<I,O,R>(fn:I->R):Emission<I,O,R>{
        return Emission.pure((v:I) -> Halt(Production(fn(v))));
    }
}
class LiftOption{
    static public function asEmiter<O>(opt:Option<O>):Emiter<O>{
        return stx.simplex.body.Emiters.fromOption(opt);
    }
}
class LiftArrowlet{
    static public function asPipe<I,O>(arw:Arrowlet<I,O>):Pipe<I,O>{
        return stx.simplex.body.Pipes.fromArrowlet(arw);
    }
}
class LiftFunction{
    static public function asFold<I,O>(fn:I->O):Fold<I,O>{
        return Folds.fromFunction(fn);
    }
}