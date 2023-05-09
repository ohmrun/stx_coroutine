package stx.coroutine.core;


typedef TransmissionDef<I,O,R,E> = Control<I> -> Coroutine<I,O,R,E>;

@:using(stx.coroutine.core.Transmission.TransmissionLift)
@:callable abstract Transmission<I,O,R,E>(TransmissionDef<I,O,R,E>) from TransmissionDef<I,O,R,E> to TransmissionDef<I,O,R,E>{
  public function new(self) this = self;
  @:noUsing static public function lift<I,O,R,E>(self:TransmissionDef<I,O,R,E>):Transmission<I,O,R,E> return new Transmission(self);
  
  @:noUsing static public inline function fromFun1R<I,O,R,E>(fn:I->Coroutine<I,O,R,E>){
    return lift((control:Control<I>) -> control.fold(
      fn,
      (e:Error<Digest>) -> __.term(e.toRefuse()),
      () -> __.stop()
    ));
  }
  public function touch(before:Void->Void,after:Void->Void):Transmission<I,O,R,E>{
    return lift(
      (control:Control<I>) -> {
        before();
        var value = this(control);
        after();
        return value;
      }
    );
  }
  @:noUsing static public inline function into<I,O,Oi,R,Ri,E>(fn:CoroutineSum<I,O,R,E>->CoroutineSum<I,Oi,Ri,E>):Coroutine<I,O,R,E>->Coroutine<I,Oi,Ri,E>{
    return fn;
  }

  public function prj():TransmissionDef<I,O,R,E> return this;
  private var self(get,never):Transmission<I,O,R,E>;
  private function get_self():Transmission<I,O,R,E> return lift(this);
}
class TransmissionLift{
  static public function mod<I,O,Oi,R,Ri,E>(self:TransmissionDef<I,O,R,E>,fn:Coroutine<I,O,R,E>->Coroutine<I,Oi,Ri,E>):Transmission<I,Oi,Ri,E>{
    return Transmission.lift(self.fn().then(fn));
  }
  static public function imply<I,O,R,E>(self:TransmissionDef<I,O,R,E>,input:I):Coroutine<I,O,R,E>{
    return self(Push(input));
  }
  //static public function reply<O,R,E>(self:TransmissionDef<Nada,O,R,E>)
}