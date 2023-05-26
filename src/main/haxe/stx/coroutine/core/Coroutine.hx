package stx.coroutine.core;

import haxe.CallStack;
import stx.alias.StdType;

@:using(stx.coroutine.core.Coroutine.CoroutineLift)
enum CoroutineSum<I,O,R,E>{
  Emit(o:O,next:Coroutine<I,O,R,E>);
  Wait(tran:Transmission<I,O,R,E>);
  Hold(held:Held<I,O,R,E>);
  Halt(r:Return<R,E>);
}

@:using(stx.coroutine.core.Coroutine.CoroutineLift)
@:forward abstract Coroutine<I,O,R,E>(CoroutineSum<I,O,R,E>) from CoroutineSum<I,O,R,E> to CoroutineSum<I,O,R,E>{
  static public var STOP = Halt(Production(Nada));

  @:noUsing static public function lift<I,O,R,E>(self:CoroutineSum<I,O,R,E>):Coroutine<I,O,R,E>{
    return new Coroutine(self);
  }
  static public var _(default,never) = CoroutineLift;
  public function new(self) this = self;

  public function is_held(){
    return switch(this){
      case Hold(_)  : true;
      default       : false; 
    }
  }
  public function prj():CoroutineSum<I,O,R,E>{
    return this;
  }
  public function provide(v:I){
    return lift(Coroutine._.provide(this,v));
  }
}
class CoroutineLift{
  static public function append<I,O,R,E>(prc0:CoroutineSum<I,O,R,E>,prc1:Thunk<Coroutine<I,O,R,E>>):Coroutine<I,O,R,E>{
    return switch (prc0){
      case Emit(head,tail)              : Emit(head,append(tail,prc1));
      case Wait(arw)                    : Wait(arw.mod(__.into(append.bind(_,prc1))));
      case Halt(Terminated(Stop))       : prc1();
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Halt(e)                      : Halt(e);
      case Hold(ft)                     : Hold(ft.mod(__.into(append.bind(_,prc1))));
    }
  }
  /**
    Insert `that` either before then next `Wait` or `Halt`;
  **/
  static public function frame<I,O,R,E>(self:CoroutineSum<I,O,R,E>,that:Tunnel<I,O,E>){
    return switch(self){
      case Wait(fn)               : append(that.toCoroutineStop(),() -> self);
      case Halt(halt)             : append(that.toCoroutineStop(),() -> self);
      case Hold(held)             : __.hold(held.mod(frame.bind(_,that)));
      case Emit(head,rest)        : __.emit(head,frame(rest,that));
    }
  }
  static public function cons<I,O,R,E>(spx:Coroutine<I,O,R,E>,o:O):Coroutine<I,O,R,E>{
    return __.emit(o,spx);
  }
  static public function provide<I,O,R,E>(self:CoroutineSum<I,O,R,E>,i:I):Coroutine<I,O,R,E>{
    var f = provide.bind(_,i);
    return switch(self){
      case Emit(head,rest)            : __.emit(head,f(rest));
      case Wait(arw)                  : arw(Push(i));
      case Hold(h)                    : __.hold(h.mod(f));
      case Halt(Production(v))        : __.exit(__.fault().explain(_ -> _.e_coroutine_provided_value_to_stopped_coroutine()));
      case Halt(Terminated(Stop))     : __.exit(__.fault().explain(_ -> _.e_coroutine_provided_value_to_stopped_coroutine()));
      case Halt(Terminated(Exit(e)))  : __.exit(e.concat(__.fault().explain(_ -> _.e_coroutine_provided_value_to_stopped_coroutine())));
    }
  }
  static public function map<I,O,Oi,R,E>(self:CoroutineSum<I,O,R,E>,fn:O->Oi):Coroutine<I,Oi,R,E>{
    var f = map.bind(_,fn);
    return switch(self){
      case Emit(head,rest)            : __.emit(fn(head),f(rest));
      case Wait(arw)                  : __.wait(arw.mod(f));
      case Hold(h)                    : __.hold(h.mod(f));
      case Halt(r)                    : __.halt(r);
    }
  }
  static public function map_i<I,Ii,O,R,E>(self:CoroutineSum<I,O,R,E>,fn:Ii->I):Coroutine<Ii,O,R,E>{
    return switch(self){
      case Emit(o,next) : Emit(o,map_i(next,fn));
      case Wait(tran)   : Wait((i:Control<Ii>) -> map_i(tran(i.map(fn)),fn)); 
      case Hold(held)   : __.hold(held.mod(map_i.bind(_,fn)));
      case Halt(r)      : Halt(r);
    }
  }
  static public inline function errata<I,O,R,E,EE>(prc:Coroutine<I,O,R,E>,fn:Refuse<E>->Refuse<EE>):Coroutine<I,O,R,EE>{
    var f : Coroutine<I,O,R,E> -> Coroutine<I,O,R,EE> = errata.bind(_,fn);
    return switch prc {
      case Emit(o, next)    : __.emit(o,f(next));
      case Wait(fn)         : __.wait(
        (ctl:Control<I>) -> ctl.fold(
          (v) -> f(fn(Push(v))),
          (e) -> Halt(Terminated(Exit(e.toRefuse()))),
          ()  -> Halt(Terminated(Stop))
        )
      );
      case Hold(ft)                     : __.hold(Held.lift(ft.map(v -> f(v))));
      case Halt(Terminated(Stop))       : __.stop();
      case Halt(Terminated(Exit(e)))    : __.exit(fn(e));
      case Halt(Production(r))          : __.prod(r);
    }
  }
  static public function map_r<I,O,R,Ri,E>(self:CoroutineSum<I,O,R,E>,fn:R->Ri):Coroutine<I,O,Ri,E>{
    var f = map_r.bind(_,fn);
    return switch(self){
      case Emit(head,rest)            : __.emit(head,f(rest));
      case Wait(arw)                  : __.wait(arw.mod(f));
      case Hold(h)                    : __.hold(h.mod(f));
      case Halt(Production(r))        : __.prod(fn(r));
      case Halt(Terminated(e))        : __.term(e);
    }
  }
  static public function map_or_halt<I,O,Oi,R,E>(self:CoroutineSum<I,O,R,E>,fn: O -> Either<Cause<E>,Oi>):Coroutine<I,Oi,R,E>{
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
  static public function relate<I,O,R,E>(self:CoroutineSum<I,O,R,E>,fn:O->Report<E>):Relate<I,R,E>{
    function rec(self:CoroutineSum<I,O,R,E>):CoroutineSum<I,Nada,R,E>{
      return switch self{
        case Emit(o, next) : fn(o).fold(
          (e) -> __.exit(e),
          ()  -> rec(next)
        );
        case Wait(fn) : __.wait(fn.mod(rec));
        case Hold(ft) : __.hold(ft.mod(rec));
        case Halt(e)  : __.halt(e);
      };
    }
    return Relate.lift(rec(self));
  }
  static public function filter<I,O,R,E>(self:CoroutineSum<I,O,R,E>,fn:O->Bool):Coroutine<I,O,R,E>{
    function rec(self:CoroutineSum<I,O,R,E
      >):CoroutineSum<I,O,R,E>{
      return switch self{
        case Emit(o, next)  : fn(o).if_else(
          () -> Emit(o,rec(next)),
          () -> rec(next)
        );
        case Wait(fn)       : __.wait(fn.mod(rec));
        case Hold(ft)       : __.hold(ft.mod(rec));
        case Halt(e)        : __.halt(e);
      };
    }
    return rec(self);
  }
  static public function map_filter<I,O,Oi,R,E>(self:CoroutineSum<I,O,R,E>,fn:O->Option<Oi>):Coroutine<I,Oi,R,E>{
    function rec(self:CoroutineSum<I,O,R,E>):CoroutineSum<I,Oi,R,E>{
      return switch self{
        case Emit(o, next)  : fn(o).fold(
          (oI)  -> Emit(oI,rec(next)),
          ()    -> rec(next)
        );
        case Wait(fn)       : __.wait(fn.mod(rec));
        case Hold(ft)       : __.hold(ft.mod(rec));
        case Halt(e)        : __.halt(e);
      };
    }
    return rec(self);
  }
  /**
    Anytime you produce a handler in capture, the value is pushed into it and removed from the stream.
  **/
  static public function partial<I,O,R,E>(self:CoroutineSum<I,O,R,E>,capture:O->Option<O->Void>):Coroutine<I,O,R,E>{
    return map_filter(
      self,
      (o) -> capture(o).fold(
        (ok) -> {
          ok(o);
          return Option.unit();
        },
        () -> Option.pure(o)
      )
    );
  }
  /**
    As with partial but starts pulling values from the stream on the first success and stops on the first failure
    after that.
  **/
  static public function window<I,O,R,E>(self:CoroutineSum<I,O,R,E>,capture:O->Option<O->Void>):Coroutine<I,O,R,E>{
    var stage = 0;
    return map_filter(
      self,
      (o) -> switch(stage){
        case 0 : capture(o).fold(
          (ok) -> {
            stage = 1;
            ok(o);
            return None;
          },
          () -> Some(o)
        );
        case 1 : capture(o).fold(
          (ok) -> {
            ok(o);
            return None;
          },
          () -> {
            stage = 2;
            return Some(o);
          }
        );
        default : Some(o);
      }
    );
  }
  static public function immediate<I,O,R,E>(self:CoroutineSum<I,O,R,E>,effect:Fiber):Coroutine<I,O,R,E>{
    return __.hold(
      Held.Pause(
        () -> {
          final nextt = Future.trigger();
          final next  = nextt.asFuture();
          effect.seq(
            Fiber.fromFuture(next)
          ).submit(); 
          return __.hold(next.map((_) -> self));
        }
      )
    );
  }
  static public function flat_map_r<I,O,R,Ri,E>(self:CoroutineSum<I,O,R,E>,fn:R->Coroutine<I,O,Ri,E>):Coroutine<I,O,Ri,E>{
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
  /** 
    
  **/
  static public function mod<I,O,Oi,R,Ri,E>(self:CoroutineSum<I,O,R,E>,fn:Coroutine<I,O,R,E>->Coroutine<I,Oi,Ri,E>):Coroutine<I,Oi,Ri,E>{
    return switch(self){
      case Wait(arw)                    : Wait(arw.mod(fn));
      case Hold(slot)                   : Hold(slot.map(fn));
      default                           : fn(self);
    }
  }
  static public function toString<I,O,R,E>(self:CoroutineSum<I,O,R,E>){
    function recurse(self:CoroutineSum<I,O,R,E>):String{
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
  /****/
  static public function escape<I,O,R,E>(self:CoroutineSum<I,O,R,E>):Coroutine<I,O,R,E>{
    return switch(self){
      case Emit(head,rest)              : rest.mod(escape);
      case Wait(arw)                    : arw(Quit(None)).mod(escape);
      case Hold(h)                      : __.hold(h.mod(__.into(escape)));
      case Halt(e)                      : __.halt(e);
    }
  }
  // static public function touch<I,O,R,E>(self:CoroutineSum<I,O,R,E>,before:Void->Void,after:Void->Void):Coroutine<I,O,R,E>{
  //   return switch(self){
  //     case Wait(arw)  : __.wait(arw.touch(before,after));
  //     case Hold(h)    : __.hold(h.touch(before,after));
  //     default         : self;
  //   }
  // }
  static public function on_return<I,O,R,E>(self:CoroutineSum<I,O,R,E>,fn:Return<R,E>->Void):Coroutine<I,O,R,E>{
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
  static public function tap<I,O,R,E>(self:CoroutineSum<I,O,R,E>,fn:Phase<I,O,R,E>->Void):Coroutine<I,O,R,E>{
    var f = tap.bind(_,fn);
    return switch self {
      case Emit(o, next)  : fn(Opt(o)); __.emit(o,f(next));
      case Wait(tran)     : __.wait(
        (ctrl:Control<I>) -> {
          fn(Ipt(ctrl));
          return f(tran(ctrl));
        }
      );
      case Hold(held)     : __.hold(held.mod(f));
      case Halt(r)        : fn(Rtn(r)); __.halt(r);
    }
  }
  static public function hook<I,O,R,E>(self:CoroutineSum<I,O,R,E>,fn:O->Void):Coroutine<I,O,R,E>{
    return self.map(
      fn.promote()
    );
  }
  static public function once<I,O,R,E>(self:CoroutineSum<I,O,R,E>,fn:O->Void):Coroutine<I,O,R,E>{
    var done = false;
    return hook(
      self,
      (o) -> done.if_else(
        () -> {},
        () -> {
          done = true;
          fn(o);
        }
      )
    );
  }
  static public function until<I,O,R,E>(self:CoroutineSum<I,O,R,E>,fn:O->Bool):Coroutine<I,O,R,E>{
    var cont = true;
    return hook(
      self,
      (o) -> {
        if(cont){
          cont = fn(o);
        }
      }
    );
  }
  static public function pause<I,O,R,E>(self:CoroutineSum<I,O,R,E>,ft:Future<Nada>):Coroutine<I,O,R,E>{
    return __.hold(
      ft.flatMap(_ -> self )
    );
  }
  static public function source<I,O,R,E>(self:CoroutineSum<I,O,R,E>,sig:Void->Future<Either<I,Cause<E>>>):Source<O,R,E>{
    return Source.lift(switch(self){
      case Emit(o,next) : __.emit(o,source(next,sig));
      case Wait(arw)    : __.hold(
        Held.Guard(
          sig().map(
            (either:Either<I,Cause<E>>) -> either.fold(
              l -> (source(arw(l),sig):CoroutineSum<Nada,O,R,E>),
              r -> __.term(r)
            )
          )
        )
      );
      case Hold(ft)     : __.hold(ft.mod(x -> (source(x,sig):CoroutineSum<Nada,O,R,E>)));
      case Halt(done)   : __.halt(done);
    });
  }
  static public function errate<I,O,R,E,EE>(self:CoroutineSum<I,O,R,E>,fn:E->EE):Coroutine<I,O,R,EE>{
    final f = errate.bind(_,fn);
    return switch(self){
      case Emit(o,next)                   : __.emit(o,f(next));
      case Wait(tran)                     : __.wait(Transmission.lift(
        function(ctrl:Control<I>) : Coroutine<I,O,R,EE> {
          return ctrl.fold(
            ok -> f(tran(Push(ok))),
            no -> __.term(Exit(no.toRefuse())),
            () -> __.stop()
          );
        }
      ));
      case Hold(held)                     : __.hold(held.mod(f));
      case Halt(Terminated(Exit(r)))      : __.exit(r.errate(fn));
      case Halt(Terminated(Stop))         : __.stop();
      case Halt(Production(r))            : __.prod(r);
    }
  }
  static public function mod_r<I,O,R,Ri,E>(self:CoroutineSum<I,O,R,E>,fn:R -> Outcome<Ri,Cause<E>>):Coroutine<I,O,Ri,E>{
    function f(self:CoroutineSum<I,O,R,E>){
      return switch(self){
        case Emit(o,next)             : __.emit(o,f(next));
        case Wait(tran)               : __.wait(tran.mod(f));
        case Hold(held)               : __.hold(held.mod(f));
        case Halt(Production(r))      : 
          final result =  fn(r).fold(
            ok -> __.prod(ok),
            no -> switch(no){
              case Stop                   : __.stop();
              case Exit(rejection)        : __.exit(rejection);
            }
          );
          result;
        case Halt(Terminated(e))    : __.term(e);
      }
    }
    return Coroutine.lift(f(self));
  }
  static public function squeeze<I,O,R,Ri,E>(self:CoroutineSum<I,O,R,E>){
    return switch(self){
      case Hold(ft) : ft.squeeze().fold(
        ok -> ok,
        () -> __.hold(ft)
      );
      default : self;
    }
  }
}