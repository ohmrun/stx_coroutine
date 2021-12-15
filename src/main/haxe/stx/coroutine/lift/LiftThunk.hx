package stx.coroutine.lift;
class LiftThunk{
  static public function toEmiter<O,E>(thk:Thunk<O>):Emiter<O,E>{
      return Emiter.fromThunk(thk);
  }
  static public function toDerive<R,E>(thk:Thunk<R>):Derive<R,E>{
      return Derive.fromThunk(thk);
  }
}