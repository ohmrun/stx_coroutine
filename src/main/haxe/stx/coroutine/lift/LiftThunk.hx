package stx.coroutine.lift;
class LiftThunk{
  static public function toEmiter<O>(thk:Thunk<O>):Emiter<O>{
      return stx.coroutine.body.Emiters.fromThunk(thk);
  }
  static public function toProducer<R>(thk:Thunk<R>):Producer<R>{
      return stx.coroutine.body.Producers.fromThunk(thk);
  }
}