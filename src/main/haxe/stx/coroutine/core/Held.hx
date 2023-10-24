package stx.coroutine.core;

typedef HeldDef<I,O,R,E> = Future<Coroutine<I,O,R,E>>;

@:using(eu.ohmrun.Fletcher.FletcherLift)
@:using(eu.ohmrun.fletcher.Provide.ProvideLift)
@:forward abstract Held<I,O,R,E>(HeldDef<I,O,R,E>) from HeldDef<I,O,R,E> to HeldDef<I,O,R,E>{
  public function new(self:HeldDef<I,O,R,E>) this = self;
  @:noUsing static public function Ready<I,O,R,E>(data:Coroutine<I,O,R,E>,?pos:Pos){
    return Future.irreversible(cb -> cb(data));
  }
  @:noUsing static public function Arrow<I,O,R,E>(arrow:Produce<Coroutine<I,O,R,E>,E>):Held<I,O,R,E>{
    return arrow.pledge().flat_fold(
      ok -> ok,
      e  -> __.exit(e)
    );
  }
  @:noUsing static public function Guard<I,O,R,E>(guard:Future<Coroutine<I,O,R,E>>,?pos:Pos):Held<I,O,R,E>{
    return lift(guard);
  }
  @:noUsing static public function Pause<I,O,R,E>(self:Void->Coroutine<I,O,R,E>):Held<I,O,R,E>{
    return lift(Future.irreversible((cb) -> cb(self())));
  }
  @:noUsing static public function lift<I,O,R,E>(fn:HeldDef<I,O,R,E>):Held<I,O,R,E>{
    return new Held(fn);
  }
  @:to public function toCoroutine():Coroutine<I,O,R,E>{
    return Hold(this);
  }
  @:noUsing static public function pure<I,O,R,E>(spx:Coroutine<I,O,R,E>):Coroutine<I,O,R,E>{
    return __.hold(lift(new Future(cb->{cb(spx); return @:privateAccess new CallbackLink(() -> {});})));
  } 
  @:noUsing static public function lazy<I,O,R,E>(spx:Thunk<Coroutine<I,O,R,E>>):Coroutine<I,O,R,E>{
    return __.hold(lift(Future.irreversible((cb) -> cb(spx()))));
  }
  public inline function mod<I1,O1,R1,E1>(fn:Coroutine<I,O,R,E>->Coroutine<I1,O1,R1,E1>):Held<I1,O1,R1,E1>{
    return new Held(this.map(fn));
  }
  public function toString():String{
    return 'HELD';
  }
}
class HeldLift{
  //static public function handle<I,O,R,E>(fn:Coroutine<I,O,R,E>->)
}