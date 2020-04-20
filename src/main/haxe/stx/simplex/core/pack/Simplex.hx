package stx.simplex.core.pack;

enum SimplexDef<I,O,R,E>{
  Emit(o:O,next:Simplex<I,O,R,E>);
  Wait(fn:Transmission<I,O,R,E>);
  Hold(ft:Held<I,O,R,E>);
  Halt(e:Return<R,E>);
}

@:using(stx.simplex.core.pack.Simplex.SimplexLift)
@:forward abstract Simplex<I,O,R,E>(SimplexDef<I,O,R,E>) from SimplexDef<I,O,R,E> to SimplexDef<I,O,R,E>{
  static public var STOP = Halt(Production(Noise));

  static public var _(default,never) = SimplexLift;
  public function new(self) this = self;

  public function held(){
    return switch(this){
      case Hold(_)  : true;
      default       : false; 
    }
  }
}
class SimplexLift{
  static public function change<I,O,R,R1,E>():Y<Simplex<I,O,R,E>,Simplex<I,O,R1,E>>{
    return function rec(fn:Y<Simplex<I,O,R,E>,Simplex<I,O,R1,E>>){
      return function(spx:Simplex<I,O,R,E>):Simplex<I,O,R1,E>{
        function f(spx:Simplex<I,O,R,E>):Simplex<I,O,R1,E> return fn(rec)(spx);
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
  static public function transform<I,O,R,I1,O1,R1,E>():Y<Simplex<I,O,R,E>,Simplex<I1,O1,R1,E>>{
    return function rec(fn:Y<Simplex<I,O,R,E>,Simplex<I1,O1,R1,E>>){
      return function(spx:Simplex<I,O,R,E>):Simplex<I1,O1,R1,E>{
        function f(spx:Simplex<I,O,R,E>):Simplex<I1,O1,R1,E> return fn(rec)(spx);
        return switch(spx){
          case Emit(head,rest)      : f(spx);
          case Wait(arw)            : f(spx);
          case Hold(h)              : __.hold(h.mod(f));
          case Halt(Production(v))  : f(__.done(v));
          case Halt(Terminated(c))  : f(__.term(c));
        }
      }
    }
  }
  static public function cons<I,O,R,E>(spx:Simplex<I,O,R,E>,o:O):Simplex<I,O,R,E>{
    return __.emit(o,spx);
  }
  @:noUsing static public function provide<I,O,R,E>(prc:Simplex<I,O,R,E>,p:I):Simplex<I,O,R,E>{
      return (function rec(fn:Y<Simplex<I,O,R,E>,Simplex<I,O,R,E>>):Simplex<I,O,R,E>->Simplex<I,O,R,E>{
        return function(spx){
          return switch(spx){
            case Wait(arw)  : arw(Push(p));
            default         : fn(rec)(spx);
          }  
        }
      })(change())(prc);
  }
  static public function map<I,O,O2,R,E>(prc:Simplex<I,O,R,E>,fn:O->O2):Simplex<I,O2,R,E>{
    return (function rec(f:Y<Simplex<I,O,R,E>,Simplex<I,O2,R,E>>):Simplex<I,O,R,E>->Simplex<I,O2,R,E>{
      return function(spx){
        return switch(spx){
          case Emit(head,rest) :
            var head  = fn(head);
            var tail  = f(rec)(rest);
            __.emit(head,tail);
          case Wait(arw)  : __.wait(arw.mod(f(rec)));
          default         : f(rec)(spx);
        }
      }
    })(transform())(prc);
  }
  static public function map_r<I,O,R,R1,E>(prc:Simplex<I,O,R,E>,fn:R->R1):Simplex<I,O,R1,E>{
    return (
      function rec(f:Y<Simplex<I,O,R,E>,Simplex<I,O,R1,E>>):Simplex<I,O,R,E>->Simplex<I,O,R1,E>{
        return function(spx){
          return switch(spx){
            case Halt(Production(v))  : __.done(fn(v));
            default                   : f(rec)(spx);
          }
        }
      }
    )(change())(prc);
  }
  static public function map_or_halt<I,O,O2,R,E>(prc:Simplex<I,O,R,E>,fn: O -> Either<Cause<E>,O2>):Simplex<I,O2,R,E>{
    return (
      function rec(f:Y<Simplex<I,O,R,E>,Simplex<I,O2,R,E>>):Simplex<I,O,R,E>->Simplex<I,O2,R,E>{
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
  static public function flat_map_r<I,O,R,R2,E>(prc:Simplex<I,O,R,E>,fn:R->Simplex<I,O,R2,E>):Simplex<I,O,R2,E>{
    return (
      function rec(f:Y<Simplex<I,O,R,E>,Simplex<I,O,R2,E>>):Simplex<I,O,R,E>->Simplex<I,O,R2,E>{
        return function(spx){
          return switch(spx){
            case Halt(Production(v))  : fn(v);
            default                   : f(rec)(spx);
          }
        }
      }
    )(change())(prc);
  }
  @:noUsing static public function one<I,O,R,E>(v:O):Simplex<I,O,R,E>{
    return __.emit(v,__.stop());
  }
  static public function each<I,O,R,E>(prc:Simplex<I,O,R,E>,fn:O->Void):Simplex<I,O,R,E>{
    return map(prc,
      (x) -> {
        fn(x);
        return x;
      }
    );
  }
  static public function mod<I,O,Oi,R,Ri,E>(self:Simplex<I,O,R,E>,fn:Simplex<I,O,R,E>->Simplex<I,Oi,Ri,E>):Simplex<I,Oi,Ri,E>{
    return Held.lazy(
      () -> fn(self)
    );
  }
  static public function returns<I,O,R,E>(spx:Simplex<I,O,R,E>):Return<R,E>{
    return switch(spx){
      case Halt(r)  : r;
      default       : Terminated(Stop);
    }
  }
  static public function toString<I,O,R,E>(self){
    function recurse(self:Simplex<I,O,R,E>):String{
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
  static public function fold<I,O,R,Z,E>(prc:Simplex<I,O,R,E>,fn:Z->O->Z,unit:Z):Simplex<I,Z,R,E>{
    return null;
  }
}

