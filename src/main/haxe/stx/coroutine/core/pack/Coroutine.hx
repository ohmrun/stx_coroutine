package stx.coroutine.core.pack;

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
}
class CoroutineLift{
  static public function change<I,O,R,R1,E>():Y<Coroutine<I,O,R,E>,Coroutine<I,O,R1,E>>{
    return function rec(fn:Y<Coroutine<I,O,R,E>,Coroutine<I,O,R1,E>>){
      return function(spx:Coroutine<I,O,R,E>):Coroutine<I,O,R1,E>{
        function f(spx:Coroutine<I,O,R,E>):Coroutine<I,O,R1,E> return fn(rec)(spx);
        return switch(spx){
          case Emit(head,rest)      : f(rest);
          case Wait(arw)            : __.wait(arw.mod(f));
          case Hold(h)              : __.hold(h.mod(f));
          case Halt(Production(v))  : f(__.done(v));
          case Halt(Terminated(c))  : f(__.term(c));
        }
      }
    }
  }
  static public function transform<I,O,R,I1,O1,R1,E>():Y<Coroutine<I,O,R,E>,Coroutine<I1,O1,R1,E>>{
    return function rec(fn:Y<Coroutine<I,O,R,E>,Coroutine<I1,O1,R1,E>>){
      return function(spx:Coroutine<I,O,R,E>):Coroutine<I1,O1,R1,E>{
        function f(spx:Coroutine<I,O,R,E>):Coroutine<I1,O1,R1,E> return fn(rec)(spx);
        return switch(spx){
          case Emit(head,rest)      : f(spx);
          case Wait(arw)            : f(spx);//NOTE
          case Hold(h)              : __.hold(h.mod(f));
          case Halt(Production(v))  : f(__.done(v));
          case Halt(Terminated(c))  : f(__.term(c));
        }
      }
    }
  }
  static public function cons<I,O,R,E>(spx:Coroutine<I,O,R,E>,o:O):Coroutine<I,O,R,E>{
    return __.emit(o,spx);
  }
  @:noUsing static public function provide<I,O,R,E>(prc:Coroutine<I,O,R,E>,p:I):Coroutine<I,O,R,E>{
      return (function rec(fn:Y<Coroutine<I,O,R,E>,Coroutine<I,O,R,E>>):Coroutine<I,O,R,E>->Coroutine<I,O,R,E>{
        return function(spx){
          return switch(spx){
            case Wait(arw)  : arw(Push(p));
            default         : fn(rec)(spx);
          }  
        }
      })(change())(prc);
  }
  static public function map<I,O,O2,R,E>(prc:Coroutine<I,O,R,E>,fn:O->O2):Coroutine<I,O2,R,E>{
    return (function rec(f:Y<Coroutine<I,O,R,E>,Coroutine<I,O2,R,E>>):Coroutine<I,O,R,E>->Coroutine<I,O2,R,E>{
      return function(spx){
        return switch(spx){
          case Emit(head,rest) :
            var head  = fn(head);
            var tail  = f(rec)(rest);
            __.emit(head,tail);
          case Wait(arw)  : __.wait(arw.mod(f(rec)));
          case Halt(halt) : __.halt(halt);
          default         : f(rec)(spx);
        }
      }
    })(transform())(prc);
  }
  static public function map_r<I,O,R,R1,E>(prc:Coroutine<I,O,R,E>,fn:R->R1):Coroutine<I,O,R1,E>{
    return (
      function rec(f:Y<Coroutine<I,O,R,E>,Coroutine<I,O,R1,E>>):Coroutine<I,O,R,E>->Coroutine<I,O,R1,E>{
        return function(spx){
          return switch(spx){
            case Halt(Production(v))  : __.done(fn(v));
            case Halt(Terminated(c))  : __.term(c);
            default                   : f(rec)(spx);
          }
        }
      }
    )(change())(prc);
  }
  static public function map_or_halt<I,O,O2,R,E>(prc:Coroutine<I,O,R,E>,fn: O -> Either<Cause<E>,O2>):Coroutine<I,O2,R,E>{
    return (
      function rec(f:Y<Coroutine<I,O,R,E>,Coroutine<I,O2,R,E>>):Coroutine<I,O,R,E>->Coroutine<I,O2,R,E>{
        return function (spx){
          return switch(spx){
            case Emit(head,rest) : 
              var tail = fn(head);
              switch(tail){
                case Left(cause) : __.term(cause);
                case Right(o)    : __.emit(o,f(rec)(rest));
              }
            case Wait(arw)  : __.wait(arw.mod(f(rec)));
            default         : f(rec)(spx);
          }
        }
      }
    )(transform())(prc);
  }
  static public function flat_map_r<I,O,R,R2,E>(prc:Coroutine<I,O,R,E>,fn:R->Coroutine<I,O,R2,E>):Coroutine<I,O,R2,E>{
    return (
      function rec(f:Y<Coroutine<I,O,R,E>,Coroutine<I,O,R2,E>>):Coroutine<I,O,R,E>->Coroutine<I,O,R2,E>{
        return function(spx){
          return switch(spx){
            case Halt(Production(v))      : fn(v);
            case Halt(Terminated(cause))  : __.term(cause);
            default                       : f(rec)(spx);
          }
        }
      }
    )(change())(prc);
  }
  @:noUsing static public function one<I,O,R,E>(v:O):Coroutine<I,O,R,E>{
    return __.emit(v,__.stop());
  }
  static public function each<I,O,R,E>(prc:Coroutine<I,O,R,E>,fn:O->Void):Coroutine<I,O,R,E>{
    return map(prc,
      (x) -> {
        fn(x);
        return x;
      }
    );
  }
  static public function mod<I,O,Oi,R,Ri,E>(self:Coroutine<I,O,R,E>,fn:Coroutine<I,O,R,E>->Coroutine<I,Oi,Ri,E>):Coroutine<I,Oi,Ri,E>{
    return Held.lazy(
      () -> fn(self)
    );
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