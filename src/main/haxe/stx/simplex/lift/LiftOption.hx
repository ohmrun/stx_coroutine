package stx.simplex.lift;

class LiftOption{
  static public function asEmiter<O>(opt:Option<O>):Emiter<O>{
      return stx.simplex.body.Emiters.fromOption(opt);
  }
}