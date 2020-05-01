package stx.coroutine.lift;

class LiftOption{
  static public function asEmiter<O>(opt:Option<O>):Emiter<O>{
      return stx.coroutine.body.Emiters.fromOption(opt);
  }
}