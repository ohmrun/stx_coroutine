package stx.coroutine.pack;

typedef SecureDef<I,E> = CoroutineSum<I,Noise,Noise,E>;

@:using(stx.coroutine.pack.Secure.SecureLift)
@:forward abstract Secure<I,E>(SecureDef<I,E>) from SecureDef<I,E> to SecureDef<I,E>{
    static public var _(default,never) = SecureLift;
    @:noUsing static public function lift<I,E>(self:SecureDef<I,E>):Secure<I,E> return new Secure(self);
    public function new(self) this = self;
    
    @:noUsing static public function handler<O,E>(fn:O->Void):Secure<O,E>{
      return lift(__.wait(
          Transmission.fromFun1R(
            function rec(o){
              fn(o);
              return __.wait(Transmission.fromFun1R(rec));
            }
          )
      ));
    }
    @:noUsing static public function nowhere(){
        return handler((x)-> {});
    }
    public function provide(v:I):Secure<I,E>{
      return lift(Coroutine._.provide(this,v));
    }
    @:from static public function fromHandler<I,E>(fn:I->Void):Secure<I,E>{
        return handler(fn);
    }
    @:to public function toCoroutine():Coroutine<I,Noise,Noise,E>{
      return this;
    } 
    @:from static public function fromCoroutine<I,E>(self:Coroutine<I,Noise,Noise,E>):Secure<I,E>{
      return lift(self);
    }
}
class SecureLift{
  static public function close<I,E>(self:SecureDef<I,E>):Effect<E>{
    function f(self:SecureDef<I,E>):EffectDef<E>{
      return switch(self){
        case Emit(o,next) : __.emit(o,f(next));
        case Wait(tran)   : __.stop();
        case Hold(held)   : __.hold(held.mod(f));
        case Halt(r)      : __.halt(r);
      }
    }
    return Effect.lift(f(self));
  }
}