package stx.simplex.core.pack;


typedef TransmissionDef<I,O,R,E> = Control<I,E> -> Simplex<I,O,R,E>;

@:using(stx.simplex.core.pack.Transmission.TransmissionLift)
@:callable abstract Transmission<I,O,R,E>(TransmissionDef<I,O,R,E>) from TransmissionDef<I,O,R,E> to TransmissionDef<I,O,R,E>{
  public function new(self) this = self;
  static public function lift<I,O,R,E>(self:TransmissionDef<I,O,R,E>):Transmission<I,O,R,E> return new Transmission(self);
  
  @:noUsing static public function fromFun1R<I,O,R,E>(fn:I->Simplex<I,O,R,E>){
    return lift((control:Control<I,E>) -> control.fold(
      fn,
      __.term      
    ));
  }
  public function touch(before:Void->Void,after:Void->Void):Transmission<I,O,R,E>{
    return lift(
      (control:Control<I,E>) -> {
        before();
        var value = this(control);
        after();
        return value;
      }
    );
  }
  @:noUsing static public function into<I,O,Oi,R,Ri,E>(fn:SimplexSum<I,O,R,E>->SimplexSum<I,Oi,Ri,E>):Simplex<I,O,R,E>->Simplex<I,Oi,Ri,E>{
    return fn;
  }

  public function prj():TransmissionDef<I,O,R,E> return this;
  private var self(get,never):Transmission<I,O,R,E>;
  private function get_self():Transmission<I,O,R,E> return lift(this);
}
class TransmissionLift{
  static public function mod<I,O,Oi,R,Ri,E>(self:Transmission<I,O,R,E>,fn:Simplex<I,O,R,E>->Simplex<I,Oi,Ri,E>):Transmission<I,Oi,Ri,E>{
    return Transmission.lift(self.fn().then(fn));
  }
}