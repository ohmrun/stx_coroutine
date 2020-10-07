package stx.fail;

@:using(stx.fail.CoroutineFailure.CoroutineFailureLift)
enum CoroutineFailureSum<E>{
  E_Coroutine_Input(i:Dynamic);
  E_Coroutine_Output(o:Dynamic);
  E_Coroutine_Return(r:Dynamic);

  E_Coroutine_Note(note:CoroutineFailureNote);
  
  E_Coroutine_Subsystem(e:E);
  E_Coroutine_Both(l:CoroutineFailure<E>,r:CoroutineFailure<E>);
}
@:using(stx.fail.CoroutineFailure.CoroutineFailureLift)
@:forward abstract CoroutineFailure<E>(CoroutineFailureSum<E>) from CoroutineFailureSum<E> to CoroutineFailureSum<E>{
  static public var _(default,never) = CoroutineFailureLift;
  public function new(self) this = self;
  static public function lift<E>(self:CoroutineFailureSum<E>):CoroutineFailure<E> return new CoroutineFailure(self);
  

  

  public function prj():CoroutineFailureSum<E> return this;
  private var self(get,never):CoroutineFailure<E>;
  private function get_self():CoroutineFailure<E> return lift(this);
}
class CoroutineFailureLift{
  static public function and<E>(self:CoroutineFailure<E>,that:CoroutineFailure<E>){
    return E_Coroutine_Both(self,that);
  }
}