package stx.simplex.pack;

typedef PipeDef<I,O,E> = SimplexSum<I,O,Noise,E>;

@:using(stx.simplex.pack.Pipe.PipeLift)
@:forward abstract Pipe<I,O,E>(PipeDef<I,O,E>) from PipeDef<I,O,E> to PipeDef<I,O,E>{
  static public var _(default,never) = PipeLift;

  public function new(self) this = self;
  @:noUsing static public function lift<I,O,E>(self:PipeDef<I,O,E>) return new Pipe(self);

  @:noUsing static public function fromFun2CallbackVoid<I,O,E>(arw:I->(O->Void)->Void):Pipe<I,O,E>{
    return lift(__.wait(
      Transmission.fromFun1R(
        function rec(i:I){ return __.hold(
          () -> {
            var future : FutureTrigger<Simplex<I,O,Noise,E>> = Future.trigger();
            arw(i,
              (o) -> {
                future.trigger(lift(__.emit(o,__.wait(Transmission.fromFun1R(rec)))));
              }
            );
            return future.asFuture();
          }
        );}
      )
    ));
  }
  @:noUsing static public function fromEmiterConstrucor<I,O,E>(cons:I->Emiter<O,E>):Pipe<I,O,E>{
    return __.wait(
      Transmission.fromFun1R(
        (i:I) -> {
          function recurse(emiter:Emiter<O,E>):Simplex<I,O,Noise,E>{
            return switch(emiter){
              case Wait(fn) : __.wait(
                Transmission.fromFun1R(cons.fn().then(recurse))
              );
              case Emit(head,tail)  : __.emit(head,recurse(tail));
              case Halt(r)          : __.halt(r);
              case Hold(h)          : __.hold(
                Held.lift(() -> h().map(
                  (pipe) -> Simplex.lift(recurse(pipe))
                ))
              );
            }
          }
          return recurse(cons(i));
        }
      )
    );
  }
  static public function fromFunction<I,O,E>(fn:I->O):Pipe<I,O,E>{
    return __.wait(
      Transmission.fromFun1R(
        function rec(i:I){ return __.emit(fn(i),__.wait(Transmission.fromFun1R(rec))); }
      )
    );
  }
  @:to public function toSimplex():Simplex<I,O,Noise,E>{
    return this;
  }
  @:from static public function fromSimplex<I,O,E>(self:Simplex<I,O,Noise,E>):Pipe<I,O,E>{
    return lift(self);
  }
}
class PipeLift{
  @:noUsing static private function lift<I,O,E>(self:PipeDef<I,O,E>) return Pipe.lift(self);
  static public function append<I,O,E>(prc0:Pipe<I,O,E>,prc1:Thunk<Pipe<I,O,E>>):Pipe<I,O,E>{
    return switch (prc0){
      case Emit(head,tail)              : Emit(head,append(tail,prc1));
      case Wait(arw)                    : Wait(arw.mod(__.into(append.bind(_,prc1))));
      case Halt(Production(Noise))      : prc1();
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Hold(ft)                     : Hold(ft.mod(__.into(append.bind(_,prc1))));
    }
  }
  static public function flat_map<I,O,O2,R,E>(prc:Pipe<I,O,E>,fn:O->Pipe<I,O2,E>):Pipe<I,O2,E>{
    return lift(switch (prc){
      case Emit(head,tail)  : append(fn(head),flat_map.bind(tail,fn));
      case Wait(arw)        : Wait(
        function(i){
          var next = arw(i);
          return flat_map(next,fn);
        }
      );
      case Halt(e)          : Halt(e);
      case Hold(ft)         : Hold(ft.mod(__.into(flat_map.bind(_,fn))));
    });
  }
  static public function always<I,O,E>(prc:Pipe<I,O,E>,v:Thunk<I>):Emiter<O,E>{
    var f = always.bind(_,v);
    return Emiter.lift(switch(prc){
      case Emit(head,tail)  : __.emit(head,f(tail));
      case Hold(ft)         : __.hold(
        Held.lift(() -> ft().map(
          (pipe) -> Simplex.lift(always(pipe,v))
        ))
      );
      case Halt(e)          : __.halt(e);
      case Wait(fn)         : always(fn(Push(v())),v);
    });
  }
}
