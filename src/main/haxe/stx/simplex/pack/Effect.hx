package stx.simplex.pack;

typedef EffectDef<E> = SimplexDef<Noise,Noise,Noise,E>;

@:using(stx.simplex.pack.Effect.EffectLift)
@:forward abstract Effect<E>(EffectDef<E>) from EffectDef<E> to EffectDef<E>{
  static public var _(default,never) = EffectLift;

  @:noUsing static public function lift<E>(self:EffectDef<E>):Effect<E>{
    return new Effect(self);
  }
  public function new(self) this = self;

  @:to public function toSimplex():Simplex<Noise,Noise,Noise,E>{
    return this;
  }
}
class EffectLift{
  static public function run<E>(e:Effect<E>):Future<Option<Cause<E>>>{   
    var t = Future.trigger();
    return t;
  }
  static public function cause_later<E>(e:Effect<E>,c:Cause<E>):Effect<E>{
    function f(e:EffectDef<E>):EffectDef<E> { return cause_later(e,c); }
    return Effect.lift(switch(e){
      case Wait(fn)                 : __.wait(fn.mod(f));
      case Emit(head,rest)          : f(rest);
      case Hold(pull)               : __.hold(pull.mod(f));
      case Halt(Terminated(cause))  : __.term(cause.next(c));
      case Halt(Production(Noise))  : __.term(c);
    });
  }
}