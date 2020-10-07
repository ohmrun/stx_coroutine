package stx.coroutine.core;

typedef HeldDef<I,O,R,E> = Slot<Coroutine<I,O,R,E>>;

@:forward(handle,value,map) abstract Held<I,O,R,E>(HeldDef<I,O,R,E>) from HeldDef<I,O,R,E>{
  public function new(self:HeldDef<I,O,R,E>) this = self;
  @:noUsing static public function lift<I,O,R,E>(fn:HeldDef<I,O,R,E>):Held<I,O,R,E>{
    return new Held(fn);
  }
  @:to public function toCoroutine():Coroutine<I,O,R,E>{
    return Hold(this);
  }
  @:noUsing static public function pure<I,O,R,E>(spx:Coroutine<I,O,R,E>):Coroutine<I,O,R,E>{
    return __.hold(Slot.Ready(spx));
  } 
  @:noUsing static public function lazy<I,O,R,E>(spx:Thunk<Coroutine<I,O,R,E>>):Coroutine<I,O,R,E>{
    return __.hold(Slot.Ready(spx()));
  }
  public inline function mod<I1,O1,R1>(fn:Coroutine<I,O,R,E>->Coroutine<I1,O1,R1,E>):Held<I1,O1,R1,E>{
    return new Held(Slot._.map(this,fn));
  }
  public function touch(before:Void->Void,after:Void->Void):Held<I,O,R,E>{
    return Slot.Guard(
      Future.NOISE.flatMap(
        (_) -> {
          before();
          return switch(this.ready){
            case true : 
              after();
              Future.sync(this.data);
            case false : 
              this.guard.handle(
                (_) -> after()
              );
              return this.guard;
          }
        }
      )
    );
  }
  public inline function handle(fn){
    Slot._.handle(this,fn);
  }
}