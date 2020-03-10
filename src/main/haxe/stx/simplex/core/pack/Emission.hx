package stx.simplex.core.pack;

import stx.simplex.core.body.Emissions;
import stx.simplex.core.head.Data.Emission in EmissionT;
import stx.simplex.core.head.Data.Simplex in SimplexT;
/**
 *  Wrapper for function Input to next Simplex, used for lifting function types.
 */
@:forward @:callable abstract Emission<I,O,R>(EmissionT<I,O,R>) from EmissionT<I,O,R> to EmissionT<I,O,R>{
    public function new(self){
      this = self;
    }
    @:from static public function pure<I,O,R>(fn:I->Simplex<I,O,R>):Emission<I,O,R>{
      return function rec(op:Operator<I>):Simplex<I,O,R>{
        return switch(op(Op.okay())){
            case Push(v) : fn(v);
            default      : Spx.wait(rec); 
        }
      }
    }
    @:from static public function fromSimplexTPure<I,O,R>(fn:I->SimplexT<I,O,R>):Emission<I,O,R>{
        return pure(fn);
    }
    static public function recursive<I,O,R>(fn:I->O):Emission<I,O,R>{
      return function recurse(op){
        return switch(op.reply()){
          case Push(v)  : Spx.wait(recurse).cons(fn(v));
          default       : Spx.wait(recurse);
        }
      }
    }
    static public function recursive1<I,O,R>(fn:I->Future<O>):Emission<I,O,R>{
        return function recurse(op){
          return switch(op.reply()){
            case Push(v)  : Spx.hold(
              () -> fn(v).map(
                (o) -> Spx.wait(recurse).cons(o)
              )
            );
            default       : Spx.wait(recurse);
          }
        }
    }
    public function mod<O1,R1>(fn:Simplex<I,O,R>->Simplex<I,O1,R1>):Emission<I,O1,R1>{
      return Emissions.mod(this,fn);
    }
}