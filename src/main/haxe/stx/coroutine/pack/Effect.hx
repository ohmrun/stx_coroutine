package stx.coroutine.pack;

using stx.Log;

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
  public function prj():EffectDef<E>{
    return this;
  }
}
class EffectLift{
  static public function run<E>(self:Effect<E>):Future<Option<Cause<E>>>{
    return Derive._.run(self.prj()).map(outcome -> outcome.fold(ok -> None,no -> Some(no)));
  }
  static public function submit<E>(eff:Effect<E>):Void{
    Derive._.run(eff.prj()).handle(
      (res) -> res.fold(
        (_) -> {},
        cause -> switch(cause){
          case Exit(e)  :
            __.log().fatal(_ -> _.pure(e));   
            throw(e); 
          default             : 
        } 
      )
    );
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
  static public function toExecute<E>(self:Effect<E>):Execute<E>{
    return Execute.lift(Fletcher.fromApi(new EffectExecute(self)));
  }
  static public function next<I,O,R,E>(self:Effect<E>,that:Coroutine<I,O,R,E>):Coroutine<I,O,R,E>{
    function f(self:Effect<E>):CoroutineSum<I,O,R,E>{
      return switch(self){
        case Emit(o,next)                 : __.hold(Held.Pause(f.bind(next)));
        case Wait(tran)                   : __.tran(
          (i:I) -> {
            return __.hold(Held.Pause(f.bind(tran(Push(Noise))))).provide(i);
          }
        );
        case Hold(held)                   : __.hold(
          held.convert(
            self -> f(self)
          )
        );
        case Halt(Production(_))          : that;
        case Halt(Terminated(c))          : __.term(c);
        default : null;
      }
    }
    return f(self);
  }
}
class EffectExecute<E> extends FletcherCls<Noise,Report<E>,Noise>{
  public var effect : Effect<E>;
  public function new(effect,?pos:Pos){
    super(pos);
    this.effect = effect;
  }
  public function defer(_:Noise,cont:Terminal<Report<E>,Noise>):Work{
    return Work.lift(
      Cycler.pure(Future.irreversible(
        (cb:Cycle->Void) -> {
          cb(handler(effect,(report) -> cont.receive(cont.value(report))));
        }
      ))
    );
  }
  private final function handler(self:EffectDef<Dynamic>,cont:Report<E>->Void):Cycle{
    final f = handler.bind(_,cont);
    return switch(self){
      case Emit(_,next) : Future.irreversible(cb -> cb(f(next)));
      case Wait(tran)   : Future.irreversible(cb -> cb(f(tran(Push(Noise)))));
      case Hold(held)   : 
        final provide : Provide<Cycle>  = Provide.lift(held.map(f));
        provide.then(
          Fletcher.Anon(
            (inpt:Cycle,cont:Terminal<Noise,Noise>) -> {
              return Work.fromCycle(inpt).seq(cont.receive(cont.value(Noise)));
            }
          )
        ).environment(
          (noise:Noise) -> {}
        ).cycle();
      case Halt(Production(_))                : 
        cont(__.report());
        Cycle.unit();
      case Halt(Terminated(Stop))             : 
        cont(__.report());
        Cycle.unit();
      case Halt(Terminated(Exit(rejection)))  : 
        cont(__.report(_ -> rejection));
        Cycle.unit();
    }
  }
  static public inline function crunch1<E>(eff:Effect<E>):Void{
    Derive._.run(eff.prj()).handle(
      res -> res.fold(
        (_) -> {},
        __.crack
      )
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
            held.environment(
              (eff) -> {
                cursor    = eff;
                suspended = false;
              }
            ).submit();
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
}