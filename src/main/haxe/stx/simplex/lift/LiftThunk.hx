package stx.simplex.lift;
class LiftThunk{
  static public function toEmiter<O>(thk:Thunk<O>):Emiter<O>{
      return stx.simplex.body.Emiters.fromThunk(thk);
  }
  static public function toProducer<R>(thk:Thunk<R>):Producer<R>{
      return stx.simplex.body.Producers.fromThunk(thk);
  }
}