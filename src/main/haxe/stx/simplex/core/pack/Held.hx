package stx.simplex.core.pack;

typedef HeldDef<I,O,R,E> = Thunk<Future<Simplex<I,O,R,E>>>;

@:callable abstract Held<I,O,R,E>(HeldDef<I,O,R,E>) from HeldDef<I,O,R,E>{
  @:to public function toSimplex():Simplex<I,O,R,E>{
    return Hold(this);
  }
  @:noUsing static public function pure<I,O,R,E>(spx:Simplex<I,O,R,E>):Simplex<I,O,R,E>{
    return __.hold(()-> Future.async(
      (fn) -> fn(spx)
    ));
  } 
  @:noUsing static public function lazy<I,O,R,E>(spx:Thunk<Simplex<I,O,R,E>>):Simplex<I,O,R,E>{
    return __.hold(
      function():Future<Simplex<I,O,R,E>>{
        return Future.async(
          (fn) -> {
            fn(spx());
          }
        ,true);
      }
    );
  }
  public function new(self:HeldDef<I,O,R,E>){
      this = self;
  }
  public function mod<I1,O1,R1>(fn:Simplex<I,O,R,E>->Simplex<I1,O1,R1,E>):Held<I1,O1,R1,E>{
    return new Held(
      function(){
        return this().map(fn);
      }
    );
  }
  public function value():Option<Simplex<I,O,R,E>>{
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