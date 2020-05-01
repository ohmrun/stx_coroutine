package stx.coroutine.core.pack;

typedef HeldDef<I,O,R,E> = Thunk<Future<Coroutine<I,O,R,E>>>;

@:callable abstract Held<I,O,R,E>(HeldDef<I,O,R,E>) from HeldDef<I,O,R,E>{
  public function new(self:HeldDef<I,O,R,E>) this = self;
  @:noUsing static public function lift<I,O,R,E>(fn:HeldDef<I,O,R,E>):Held<I,O,R,E>{
    return new Held(fn);
  }
  @:to public function toCoroutine():Coroutine<I,O,R,E>{
    return Hold(this);
  }
  @:noUsing static public function pure<I,O,R,E>(spx:Coroutine<I,O,R,E>):Coroutine<I,O,R,E>{
    return __.hold(()-> Future.async(
      (fn) -> fn(spx)
    ));
  } 
  @:noUsing static public function lazy<I,O,R,E>(spx:Thunk<Coroutine<I,O,R,E>>):Coroutine<I,O,R,E>{
    return __.hold(
      function():Future<Coroutine<I,O,R,E>>{
        return Future.async(
          (fn) -> {
            fn(spx());
          }
        ,true);
      }
    );
  }
  public function mod<I1,O1,R1>(fn:Coroutine<I,O,R,E>->Coroutine<I1,O1,R1,E>):Held<I1,O1,R1,E>{
    return new Held(
      function(){
        return this().map(fn);
      }
    );
  }
  public function touch(before:Void->Void,after:Void->Void):Held<I,O,R,E>{
    return new Held(
      function(){
        before();
        var future = this();
        future.handle((_) -> after());
        return future;
      }
    );
  }
  public function value():Option<Coroutine<I,O,R,E>>{
    var v = None;
    var cancel = this().handle(
      (x) -> v = Some(x)
    );
    if(v == None){
      cancel.dissolve();
    }
    return v;
  }
}