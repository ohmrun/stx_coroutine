package stx.simplex.body;


class Effects{
  static public function run(effect:Effect):Future<Option<Error>>{
    var t = Future.trigger();
    function recurse(effect:Effect):Void{
      switch(effect){
        case Halt(Terminated(cause))  : t.trigger(cause.toOption());   
        case Halt(Production(ret))    : t.trigger(None);
        case Emit(Noise,next)         : recurse(next);
        case Wait(arw)                : recurse(arw(Noise));
        case Hold(ft)                 : ft.handle(recurse); 
      };
    }
    recurse(effect);
    return t.asFuture(); 
  }
  /*
  static public function steps(effect:Effect):Void->Bool{
    function recurse(effect)
  }*/
}