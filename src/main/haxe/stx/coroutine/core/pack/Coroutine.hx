package stx.coroutine.core.pack;

import haxe.CallStack;
import stx.alias.StdType;

enum CoroutineSum<I,O,R,E>{
  Emit(o:O,next:Coroutine<I,O,R,E>);
  Wait(fn:Transmission<I,O,R,E>);
  Hold(ft:Held<I,O,R,E>);
  Halt(e:Return<R,E>);
}

@:using(stx.coroutine.core.pack.Coroutine.CoroutineLift)
@:forward abstract Coroutine<I,O,R,E>(CoroutineSum<I,O,R,E>) from CoroutineSum<I,O,R,E> to CoroutineSum<I,O,R,E>{
  static public var STOP = Halt(Production(Noise));

  @:noUsing static public function lift<I,O,R,E>(self:CoroutineSum<I,O,R,E>):Coroutine<I,O,R,E>{
    return new Coroutine(self);
  }
  static public var _(default,never) = CoroutineLift;
  public function new(self) this = self;

  public function held(){
    return switch(this){
      case Hold(_)  : true;
      default       : false; 
    }
  }
  public function prj():CoroutineSum<I,O,R,E>{
    return this;
  }
}
class CoroutineLift{
  static public function cons<I,O,R,E>(spx:Coroutine<I,O,R,E>,o:O):Coroutine<I,O,R,E>{
    return __.emit(o,spx);
  }
  static public function provide<I,O,R,E>(self:Coroutine<I,O,R,E>,i:I):Coroutine<I,O,R,E>{
    var f = provide.bind(_,i);
    return switch(self){
      case Emit(head,rest)            : __.emit(head,f(rest));
      case Wait(arw)                  : arw(Push(i));
      case Hold(h)                    : __.hold(h.mod(f));
      case Halt(Production(v))        : __.exit(__.fault().of(E_Coroutine_Note(E_Coroutine_Note_HangingInput).and(E_Coroutine_Input(i).and(E_Coroutine_Output(v)))));
      case Halt(Terminated(Stop))     : __.exit(__.fault().of(E_Coroutine_Note(E_Coroutine_Note_UnexpectedStop).and(E_Coroutine_Input(i))));
      case Halt(Terminated(Exit(e)))  : __.exit(e.map(E_Coroutine_Both.bind(E_Coroutine_Input(i))));
    }
  }
  static public function map<I,O,Oi,R,E>(self:Coroutine<I,O,R,E>,fn:O->Oi):Coroutine<I,Oi,R,E>{
    var f = map.bind(_,fn);
    return switch(self){
      case Emit(head,rest)            : __.emit(fn(head),f(rest));
      case Wait(arw)                  : __.wait(arw.mod(f));
      case Hold(h)                    : __.hold(h.mod(f));
      case Halt(r)                    : __.halt(r);
    }
  }
  static public inline function errata<I,O,R,E,EE>(prc:Coroutine<I,O,R,E>,fn:Err<CoroutineFailure<E>>->Err<CoroutineFailure<EE>>):Coroutine<I,O,R,EE>{
    var f : Coroutine<I,O,R,E> -> Coroutine<I,O,R,EE> = errata.bind(_,fn);
    return switch prc {
      case Emit(o, next)    : __.emit(o,f(next));
      case Wait(fn)         : __.wait(
        (ctl:Control<I,EE>) -> ctl.fold(
          (v) -> f(fn(Push(v))),
          (c) -> switch(c){
            case Stop     : Halt(Terminated(Stop));
            case Exit(e)  : Halt(Terminated(Exit(e)));
          }
        )
      );
      case Hold(ft)         : __.hold(ft.map(v -> f(v)));
      case Halt(Terminated(Stop))       : __.stop();
      case Halt(Terminated(Exit(e)))    : __.exit(fn(e));
      case Halt(Production(r))          : __.prod(r);
    }
  }
  static public function map_r<I,O,R,Ri,E>(self:Coroutine<I,O,R,E>,fn:R->Ri):Coroutine<I,O,Ri,E>{
    var f = map_r.bind(_,fn);
    return switch(self){
      case Emit(head,rest)            : __.emit(head,f(rest));
      case Wait(arw)                  : __.wait(arw.mod(f));
      case Hold(h)                    : __.hold(h.mod(f));
      case Halt(Production(r))        : __.prod(fn(r));
      case Halt(Terminated(e))        : __.term(e);
    }
  }
  static public function map_or_halt<I,O,Oi,R,E>(self:Coroutine<I,O,R,E>,fn: O -> Either<Cause<E>,Oi>):Coroutine<I,Oi,R,E>{
    var f = map_or_halt.bind(_,fn);
    return switch(self){
      case Emit(head,rest)            : fn(head).fold(
        (l) -> __.term(l),
        (r) -> __.emit(r,f(rest))
      );
      case Wait(arw)                  : __.wait(arw.mod(f));
      case Hold(h)                    : __.hold(h.mod(f));
      case Halt(Production(r))        : __.prod(r);
      case Halt(Terminated(e))        : __.term(e);
    }
  }
  static public function flat_map_r<I,O,R,Ri,E>(self:Coroutine<I,O,R,E>,fn:R->Coroutine<I,O,Ri,E>):Coroutine<I,O,Ri,E>{
    var f = flat_map_r.bind(_,fn);
    return switch(self){
      case Emit(head,rest)            : __.emit(head,f(rest));
      case Wait(arw)                  : __.wait(arw.mod(f));
      case Hold(h)                    : __.hold(h.mod(f));
      case Halt(Production(r))        : fn(r);
      case Halt(Terminated(e))        : __.term(e);
    }
  }
  @:noUsing static public function one<I,O,R,E>(v:O):Coroutine<I,O,R,E>{
    return __.emit(v,__.stop());
  }
  static public function mod<I,O,Oi,R,Ri,E>(self:Coroutine<I,O,R,E>,fn:Coroutine<I,O,R,E>->Coroutine<I,Oi,Ri,E>):Coroutine<I,Oi,Ri,E>{
    return switch(self){
      case Wait(arw)                    : Wait(arw.mod(fn));
      case Hold(slot)                   : Hold(slot.map(fn));
      default                           : fn(self);
    }
  }
  static public function returns<I,O,R,E>(spx:Coroutine<I,O,R,E>):Return<R,E>{
    return switch(spx){
      case Halt(r)  : r;
      default       : Terminated(Stop);
    }
  }
  static public function toString<I,O,R,E>(self){
    function recurse(self:Coroutine<I,O,R,E>):String{
      return switch(self){
        case Emit(head,rest)              : '!<${head}>${recurse(rest)}';
        case Wait(arw)                    : '->';
        case Hold(h)                      : '[?]';
        case Halt(Terminated(Stop))       : '#.';
        case Halt(e)                      : '#$e';
      }
    }
    return recurse(self);
  }
  static public function escape<I,O,R,E>(self:Coroutine<I,O,R,E>):Coroutine<I,O,R,E>{
    return switch(self){
      case Emit(head,rest)              : rest.mod(escape);
      case Wait(arw)                    : arw(Quit(Stop)).mod(escape);
      case Hold(h)                      : __.hold(h.mod(__.into(escape)));
      case Halt(e)                      : __.halt(e);
    }
  }
  static public function touch<I,O,R,E>(self:Coroutine<I,O,R,E>,before:Void->Void,after:Void->Void):Coroutine<I,O,R,E>{
    return switch(self){
      case Wait(arw)  : __.wait(arw.touch(before,after));
      case Hold(h)    : __.hold(h.touch(before,after));
      default         : self;
    }
  }
  static public function on_return<I,O,R,E>(self:Coroutine<I,O,R,E>,fn:Return<R,E>->Void):Coroutine<I,O,R,E>{
    var f = __.into(on_return.bind(_,fn));
    return switch(self){
      case Wait(arw)        : __.wait(arw.mod(f));
      case Emit(head,tail)  : __.emit(head,tail.mod(f));
      case Hold(ft)         : __.hold(ft.mod(f));
      case Halt(ret)        : 
        fn(ret);
        __.halt(ret);
    }
  }
}