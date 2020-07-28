package stx.coroutine.pack;

import haxe.MainLoop;

typedef EffectDef<E> = CoroutineSum<Noise,Noise,Noise,E>;

@:using(stx.coroutine.pack.Effect.EffectLift)
@:forward abstract Effect<E>(EffectDef<E>) from EffectDef<E> to EffectDef<E>{
  static public var _(default,never) = EffectLift;

  @:noUsing static public function lift<E>(self:EffectDef<E>):Effect<E>{
    return new Effect(self);
  }
  public function new(self) this = self;

  @:to public function toCoroutine():Coroutine<Noise,Noise,Noise,E>{
    return this;
  }
  @:from static public function fromCoroutine<E>(self:Coroutine<Noise,Noise,Noise,E>):Effect<E>{
    return lift(self);
  }
}
class EffectLift{
  static public function run<E>(eff:Effect<E>):Future<Option<Cause<E>>>{
    var t     = Future.trigger();
    run1Inner(eff,t);
    return t;
  }
  static function run1Inner<E>(eff:EffectDef<E>,f:FutureTrigger<Option<Cause<E>>>){
    var now = eff;

    while(true){
      switch(now){
        case Halt(h)      : switch(h){
          case Terminated(cause)    : f.trigger(Some(cause));
          default                   : f.trigger(None);
        }
        break;
        case Hold(ft)     : 
          ft.handle((x) -> run1Inner(x,f));
          break;
        case Wait(fn)     :
          now = fn(Push(Noise));
        case Emit(_,nxt)  :
          now = nxt;
      }
    }
  }
  static public function run1<E>(eff:Effect<E>):Future<Option<Cause<E>>>{   
    var uuid  = __.uuid();
    var t     = Future.trigger();
    function handler(eff:Effect<E>){
      switch(eff){
        case Halt(h) : 
          switch(h){
            case Terminated(cause)    : t.trigger(Some(cause));
            default                   : t.trigger(None);
          }
        case Hold(held)               : 
          var event = MainLoop.add(()->{});//TODO backoff?
          held.handle(
            (eff) -> {
              event.stop();
              MainLoop.addThread(handler.bind(eff));
            }
          );
        case Wait(fn)                 : 
          MainLoop.addThread(
            () -> handler(fn(Push(Noise)))
          );
        case Emit(_,tail)             : 
            MainLoop.addThread(handler.bind(tail));
          
      }
    }
    handler(eff);
    return t;
  }
  static public inline function crunch1<E>(eff:Effect<E>):Void{
    run(eff).handle(
      __.crack
    );
  }
  static public inline function crunch<E>(eff:Effect<E>):Void{
    var cursor        = eff;
    var suspended     = false;
    var done          = false;

    function handler(){
      //trace(cursor);
      switch(cursor){
        case Halt(h) :
          switch(h){
            case Terminated(Exit(error))      : throw error;
              default                         : 
          }
          done = true;
        case Hold(held)             :
            suspended = true;
            held.handle(
              (eff) -> {
                cursor    = eff;
                suspended = false;
              }
            );
        case Wait(fn)               :
            cursor = fn(Noise);
        case Emit(_,tail)           : 
            cursor = tail;
      }
    }
    while(!done){
      if(!suspended){
        handler();
      }
    }
  }
  static public function cause_later<E>(e:Effect<E>,c:Cause<E>):Effect<E>{
    function f(e:EffectDef<E>):EffectDef<E> { return cause_later(e,c); }
    return Effect.lift(switch(e){
      case Wait(fn)                 : __.wait(fn.mod(f));
      case Emit(head,rest)          : f(rest);
      case Hold(pull)               : __.hold(pull.mod(f));
      case Halt(Terminated(cause))  : __.term(cause.next(c));
      case Halt(Production(Noise))  : __.term(c);
      case Halt(e)                  : __.halt(e);
    });
  }
}