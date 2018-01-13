package stx.simplex.core.pack;

import stx.simplex.core.head.Data.Emission in EmissionT;

/**
 *  Wrapper for function Input to next Simplex, used for lifting function types.
 */
@:forward @:callable abstract Emission<I,O,R>(EmissionT<I,O,R>) from EmissionT<I,O,R> to EmissionT<I,O,R>{
    public function new(self){
        this = self;
    }
    static public function pure<I,O,R>(fn:I->Simplex<I,O,R>):Emission<I,O,R>{
        return function(ctl:Control<I>):Simplex<I,O,R>{
            return ctl.lift(fn);
        }
    }
    static public function recursive<I,O,R>(fn:I->O):Emission<I,O,R>{
        return function recurse(ctl:Control<I>):Simplex<I,O,R>{
            return ctl.lift(
                (i:I) -> Emit(fn(i),Wait(recurse))
            );
        }
    }
    static public function recursive1<I,O,R>(fn:I->Future<O>):Emission<I,O,R>{
        return function recurse(ctl:Control<I>):Simplex<I,O,R>{
            return ctl.lift(
                (i:I) -> Hold(fn(i).map(
                    (o:O) -> Emit(o,Wait(recurse)))
                )
            );
        }
    }
}