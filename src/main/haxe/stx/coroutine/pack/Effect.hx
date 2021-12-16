package stx.coroutine.pack;

//TODO:  implement using stx.Stream
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
}
class EffectLift{
  static public function submit<E>(eff:Effect<E>):Void{
    run(eff).handle(
      (cause) -> switch(cause){
        case Some(Exit(e))  :
          __.log().fatal(_ -> _.pure(e));   
          throw(e);
        default             : 
      } 
    );
  }
  static public function run<E>(eff:Effect<E>):Future<Option<Cause<E>>>{
    __.log().info('run $eff');
    var t     = Future.trigger();
    loop(eff,t);
    return t;
  }
  static function loop<E>(eff:EffectDef<E>,f:FutureTrigger<Option<Cause<E>>>){
    __.log().debug('loop $eff');
    var now = eff;

    while(true){
      switch(now){
        case Halt(h)      : switch(h){
          case Terminated(cause)    : f.trigger(Option.pure(cause));
          default                   : f.trigger(Option.unit());
        }
        break;
        case Hold(ft)     :
          __.log().debug('hold'); 
          ft.environment(
            (x) -> {
              __.log().debug('hold:release');
              loop(x,f);
            }
          ).submit();
          break;
        case Wait(fn)     : now = fn(Push(Noise));
        case Emit(_,nxt)  : now = nxt;
      }
    }
  }
  static public inline function crunch1<E>(eff:Effect<E>):Void{
    run(eff).handle(__.crack);
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
  static public function toExecute<E>(self:Effect<E>):Execute<CoroutineFailure<E>>{
    return Execute.lift(Fletcher.fromApi(new EffectExecute(self)));
  }
}
class EffectExecute<E> implements FletcherApi<Noise,Report<CoroutineFailure<E>>,Noise>{
  public var effect : Effect<E>;
  public function new(effect){
    this.effect = effect;
  }
  public function defer(_:Noise,cont:Terminal<Report<CoroutineFailure<E>>,Noise>):Work{
    return __.option(
      Future.irreversible(
        (cb:Cycle->Void) -> {
          cb(handler(effect,(report) -> cont.receive(cont.value(report))));
        }
      )
    );
  }
  private final function handler(self:EffectDef<Dynamic>,cont:Report<CoroutineFailure<E>>->Void):Cycle{
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
}