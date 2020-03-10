package stx.simplex.core.pack;

import stx.fn.pack.Thunk;
import stx.simplex.core.body.Helds;
import stx.simplex.core.head.data.Held in HeldT;

@:callable abstract Held<I,O,R>(HeldT<I,O,R>) from HeldT<I,O,R>{
  @:to public function toInterface():Interface<I,O,R>{
    return toSimplex();
  }
  @:to public function toSimplex():Simplex<I,O,R>{
    return Hold(this);
  }
  static public function unit<I,O,R>(spx:Simplex<I,O,R>):Simplex<I,O,R>{
    return Spx.hold(()-> Future.async(
      (fn) -> fn(spx)
    ));
  } 
  static public function lazy<I,O,R>(spx:Thunk<Simplex<I,O,R>>):Simplex<I,O,R>{
    return Spx.hold(
      function():Future<Simplex<I,O,R>>{
        return Future.async(
          (fn) -> {
            fn(spx());
          }
        ,true);
      }
    );
  }
  public function new(self:HeldT<I,O,R>){
      this = self;
  }
  public function mod<I1,O1,R1>(fn:Simplex<I,O,R>->Simplex<I1,O1,R1>):Held<I1,O1,R1>{
    return new Held(
      function(){
        return this().map(fn);
      }
    );
  }
  public function reply(?schedule):Simplex<I,O,R>{
    var scheduler = schedule == null ? new Scheduler().iterator() : schedule;
    var val       = None;
    this().handle(
      (v) -> { val = Some(v); }
    );
    return Spx.hold(
      function recurse(){
        return switch([val,scheduler.hasNext()]){
          case [ None , true ] :
            Helds.poll(
              recurse,
              scheduler.next()
            );
          case [ Some(v), _ ]  :
            lazy(()->v);
          case [ None, false ] : 
            Helds.hung(this);
        }
      }
    );
  }
  public function value():Option<Simplex<I,O,R>>{
    var v = None;
    var cancel = this().handle(
      (x) -> v = Some(x)
    );
    if(v == None){
      cancel.dissolve();
    }
    return v;
  }
  public function poll<I,O,R>(?time:Float):Simplex<I,O,R>{
    return Helds.poll(this,time);
  }
  public function hung<I,O,R>(?e):Simplex<I,O,R>{
    return Helds.hung(this,e);
  }
}