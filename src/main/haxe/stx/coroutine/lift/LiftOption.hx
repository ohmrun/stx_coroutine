package stx.coroutine.lift;

class LiftOption{
  static public function asEmiter<O,E>(opt:Option<O>):Emiter<O,E>{
      return Emiter.fromOption(opt);
  }
}