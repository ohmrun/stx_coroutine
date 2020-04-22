package stx.simplex.core.pack;

enum SimplexSum<I,O,R,E>{
  Emit(o:O,next:Simplex<I,O,R,E>);
  Wait(fn:Transmission<I,O,R,E>);
  Hold(ft:Held<I,O,R,E>);
  Halt(e:Return<R,E>);
}

@:using(stx.simplex.core.pack.Simplex.SimplexLift)
@:forward abstract Simplex<I,O,R,E>(SimplexSum<I,O,R,E>) from SimplexSum<I,O,R,E> to SimplexSum<I,O,R,E>{
  static public var STOP = Halt(Production(Noise));

  @:noUsing static public function lift<I,O,R,E>(self:SimplexSum<I,O,R,E>):Simplex<I,O,R,E>{
    return new Simplex(self);
  }
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
          case Wait(arw)            : f(spx);//NOTE
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
            case Halt(Production(v))      : fn(v);
            case Halt(Terminated(cause))  : __.term(cause);
            default                       : f(rec)(spx);
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
  static public function merge<I,O,R,E>(self:Simplex<I,O,R,E>,that:Simplex<I,O,R,E>,selector:Simplex<I,O,R,E>->Simplex<I,O,R,E>->Bool):Simplex<I,O,R,E>{
    var side = selector(self,that);
    var data = side ? that : self;
    var next = side ? self : that;
    var f    = __.into(side ? merge.bind(self,_,selector) : merge.bind(_,self,selector));

    if(side){that = data;}else{self = data;}
    return switch(data){
      case Emit(head,rest)                  : __.emit(head,Held.lazy(() -> f(rest)));
      case Wait(arw)                        : __.wait(arw.mod(f));
      case Hold(h)                          : __.hold(h.mod(f));
      case Halt(r)                          : 
        function res(spx) {
          return switch(spx){
            case Emit(_, _)                 : __.fail(__.fault().err(E_IndexOutOfBounds));
            case Wait(_)                    : __.fail(__.fault().any("produced Wait after `escape` called"));
            case Hold(ft)                   : __.hold(ft.mod(res));//be nice to the asynhronous.
            case Halt(Terminated(Stop))     : __.halt(r);
            case Halt(Terminated(Exit(e)))  : __.fail(e);
            case Halt(Production(t))        : __.fail(__.fault().any("produced Return after `escape` called"));
          }
        }
        res(next.escape());
    }
  }
  static public function escape<I,O,R,E>(self:Simplex<I,O,R,E>):Simplex<I,O,R,E>{
    return switch(self){
      case Emit(head,rest)              : rest.mod(escape);
      case Wait(arw)                    : arw(Quit(Stop)).mod(escape);
      case Hold(h)                      : __.hold(h.mod(__.into(escape)));
      case Halt(e)                      : __.halt(e);
    }
  }
  static public function touch<I,O,R,E>(self:Simplex<I,O,R,E>,before:Void->Void,after:Void->Void):Simplex<I,O,R,E>{
    return switch(self){
      case Wait(arw)  : __.wait(arw.touch(before,after));
      case Hold(h)    : __.hold(h.touch(before,after));
      default         : self;
    }
  }
}
