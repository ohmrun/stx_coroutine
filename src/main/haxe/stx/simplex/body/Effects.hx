package stx.simplex.body;

class Effects{
  #if sys
  static public function run(e:Effect,?schedule:Iterator<Float>):Future<Option<Cause>>{   
    var t = Future.trigger();
    function inner(e:Effect):Option<Cause>{
      trace('inner $e');
      return switch(e.state){
        case Seek(Hung(e),next)                             : Some(e);
        case Seek(Poll(t),next)                             :
          if(t == null){
            t = 0.5;
          }
          Sys.sleep(t);
          inner(next);
        case Seek(_,next)                             : inner(next);
        case Emit(emit)                               : inner(emit.next);
        case Hold(h)                                  : inner(h.reply(schedule));
        case Wait(fn)                                 : inner(fn(Operator.unit()));
        case Halt(Production(Noise))                  : None;
        case Halt(Return.Terminated(cause))           : Some(cause); 
      }
    }
    t.trigger(inner(e));
    return t.asFuture();
  }
  #else
    //TODO schedule has a use?
    static public function run(effect:Effect,?schedule):Future<Option<Cause>>{
      var t = Future.trigger();
      function recurse(effect:Effect):Void{
        switch(effect){
          case Halt(Terminated(cause))        : t.trigger(Some(cause));   
          case Halt(Production(ret))          : t.trigger(None);
          case Emit(Noise,next)               : recurse(next);
          case Wait(arw)                      : recurse(arw(Noise));
          case Hold(Hung(ft))                 : 
            ft.defer(recurse);
          case Hold(Poll(status))             : recurse(status());
          case Hold(Open(status))             : recurse(status());
        };
      }
      recurse(effect);
      return t.asFuture(); 
    }
  #end
  static public function causeLater(e:Effect,c:Cause):Effect{
    function f(e:Effect):Effect { return causeLater(e,c); }
    return switch(e.state){
      case Seek(advice,next)        : Spx.seek(advice,f(next));
      case Wait(fn)                 : Spx.wait(fn.mod(f));
      case Emit(emit)               : f(emit.next);
      case Hold(pull)               : Spx.hold(pull.mod(f));
      case Halt(Terminated(cause))  : Spx.term(cause.next(c));
      case Halt(Production(Noise))  : Spx.term(c);
    }
  }
}