package stx.simplex.body;

class Folds{
  static public function fromFunction<I,O>(fn:I->O):Fold<I,O>{
    return Constructors.wait(
      (x:I) -> Constructors.done(fn(x))
    );
  }
  //static public function toPipe    
}