package stx.coroutine.lift;
class LiftThunk{
  static public function toEmiter<O>(thk:Thunk<O>):Emiter<O>{
      return stx.coroutine.body.Emiters.fromThunk(thk);
  }
  static public function toDerive<R>(thk:Thunk<R>):Derive<R>{
      return stx.coroutine.body.Derives.fromThunk(thk);
  }
}