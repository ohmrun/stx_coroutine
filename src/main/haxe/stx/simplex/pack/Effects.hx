package stx.simplex.pack;

import stx.simplex.core.Data;

class Effects{
  static public function run(effect:Effect):Future<Cause>{
    var t = Future.trigger();
    function recurse(effect:Effect):Void{
      switch(effect){
        case Halt(Terminated(cause))  : t.trigger(cause);   
        case Halt(Production(ret))    : t.trigger(Finished);
        case Emit(Noise,next)         : recurse(next);
        case Wait(arw)                : recurse(arw(Noise));
        case Held(ft)                 : ft.handle(recurse); 
      };
    }
    recurse(effect);
    return t.asFuture(); 
  }
}