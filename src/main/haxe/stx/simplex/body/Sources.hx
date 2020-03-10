package stx.simplex.body;


class Sources{
  static public function toEmiter<O,R>(cncd:Source<O,R>,cb:R->O):Emiter<O>{
    function recurse(cncd:Source<O,R>):Source<O,R>{
      return switch(cncd.state){
        case Halt(Terminated(cause))  : Spx.term(cause);
        case Halt(Production(ret))    : Spx.stop().cons(cb(ret));
        case Emit(emit)               : Spx.emit(emit.mod(recurse));
        case Wait(arw)                : Spx.wait(arw.mod(recurse));
        case Hold(ft)                 : Spx.hold(ft.mod(recurse));
      } 
    }
    return recurse(cncd);
  }
  static public function filter<O,R>(self:Source<O,R>,fn:O->Bool):Source<O,R>{
    return switch(self){
      case Emit(head,tail) : 
        if(fn(head)){
          Emit(head,filter(tail,fn));
        }else{
          filter(tail,fn);
        }
      case Wait(fn)        : Wait(fn);
      case Hold(ft)        : Hold(ft);
      case Halt(t)         : Halt(t);
    }
  }
  static public function mapFilter<T,U,R>(src:Source<T,R>,fn:T->Option<U>):Source<U,R>{
    return switch(src){
      case Emit(head,tail) :
        switch(fn(head)){
          case None     : mapFilter(tail,fn);
          case Some(v)  : Emit(v,mapFilter(tail,fn));
        } 
      case Wait(arw)       : Wait(arw.then(mapFilter.bind(_,fn)));
      case Hold(ft)        : Hold(ft.map(mapFilter.bind(_,fn)));
      case Halt(t)         : Halt(t);
    }
  }
}