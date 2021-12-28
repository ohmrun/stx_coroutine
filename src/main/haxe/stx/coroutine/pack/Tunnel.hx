package stx.coroutine.pack;

typedef TunnelDef<I,O,E> = CoroutineSum<I,O,Noise,E>;

@:using(stx.coroutine.pack.Tunnel.TunnelLift)
@:forward abstract Tunnel<I,O,E>(TunnelDef<I,O,E>) from TunnelDef<I,O,E> to TunnelDef<I,O,E>{
  static public var _(default,never) = TunnelLift;

  public function new(self) this = self;
  @:noUsing static public function lift<I,O,E>(self:TunnelDef<I,O,E>) return new Tunnel(self);

  @:noUsing static public function fromFun2CallbackVoid<I,O,E>(arw:I->(O->Void)->Void):Tunnel<I,O,E>{
    return lift(__.wait(
      Transmission.fromFun1R(
        function rec(i:I){ 
          var future : FutureTrigger<Coroutine<I,O,Noise,E>> = Future.trigger();
          arw(i,
            (o) -> {
              future.trigger(__.emit(o,__.wait(Transmission.fromFun1R(rec))));
            }
          );
          return __.hold(Held.Guard(future));
        }
      )
    ));
  }
  @:noUsing static public function fromEmiterConstrucor<I,O,E>(cons:I->Emiter<O,E>):Tunnel<I,O,E>{
    return __.wait(
      Transmission.fromFun1R(
        (i:I) -> {
          function recurse(emiter:Emiter<O,E>):Coroutine<I,O,Noise,E>{
            return switch(emiter){
              case Wait(fn) : __.wait(
                Transmission.fromFun1R(cons.fn().then(recurse))
              );
              case Emit(head,tail)  : __.emit(head,recurse(tail));
              case Halt(r)          : __.halt(r);

              case Hold(h)          : __.hold(
                Held.lift(h.map(
                  (pipe) -> Coroutine.lift(recurse(pipe))
                ))
              );
            }
          }
          return recurse(cons(i));
        }
      )
    );
  }
  static public function fromFunction<I,O,E>(fn:I->O):Tunnel<I,O,E>{
    return __.wait(
      Transmission.fromFun1R(
        function rec(i:I){ return __.emit(fn(i),__.wait(Transmission.fromFun1R(rec))); }
      )
    );
  }
  @:to public function toCoroutine():Coroutine<I,O,Noise,E>{
    return this;
  }
  @:from static public function fromCoroutine<I,O,E>(self:Coroutine<I,O,Noise,E>):Tunnel<I,O,E>{
    return lift(self);
  }
}
class TunnelLift{
  @:noUsing static private function lift<I,O,E>(self:TunnelDef<I,O,E>) return Tunnel.lift(self);
  static public function append<I,O,E>(prc0:Tunnel<I,O,E>,prc1:Thunk<Tunnel<I,O,E>>):Tunnel<I,O,E>{
    return switch (prc0){
      case Emit(head,tail)              : Emit(head,append(tail,prc1));
      case Wait(arw)                    : Wait(arw.mod(__.into(append.bind(_,prc1))));
      case Halt(Production(Noise))      : prc1();
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Halt(e)                      : Halt(e);
      case Hold(ft)                     : Hold(ft.mod(__.into(append.bind(_,prc1))));
    }
  }
  static public function flat_map<I,O,O2,R,E>(prc:Tunnel<I,O,E>,fn:O->Tunnel<I,O2,E>):Tunnel<I,O2,E>{
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
  static public function emiter<I,O,E>(self:Tunnel<I,O,E>,that:Emiter<I,E>):Emiter<O,E>{
    __.log().debug('emiter: $self');
    var f = emiter.bind(_,that);
    return Emiter.lift(switch(self){
      case Emit(head,tail)      : __.emit(head,f(tail));
      case Hold(ft)             : __.hold(
        Held.lift(ft.map(
          (pipe) -> Coroutine.lift(emiter(pipe,that))
        ))
      );
      case Halt(e)              : __.halt(e);
      case Wait(fn)             : 
        switch(that){
          case Emit(head,tail)  : emiter(fn(head),tail); 
          case Hold(ft)         : __.hold(Held.lift(ft.map(
            (pipe) -> Coroutine.lift(emiter(self,pipe))
          )));
          case Wait(arw)        : emiter(self,arw(Push(Noise)));
          case Halt(done)       : __.halt(done);
        }
    });
  }
  // //request next value rudely
  // static public function demand<I,O,E>(self:Tunner<I,O,E>,i:I,fn:O->Tunnel<I,O,E>):Tunnel<I,O,E>{
  
  // }
  /**
   Reorders the outputs such that the first `true` from `fn` is produced first. `Rejection` if the stream
   terminates without ever returning `true`. Infinite `Tunnel` unaffected.
  **/
  // static public function require<I,O,Z,E>(self:TunnelDef<I,O,E>,fn:Arrange<O,Tunnel<I,O,E>>->Option<Tunnel<I,O,E>>):Tunnel<I,O,E>{
  //   function rec(self:TunnelDef<I,O,E>):TunnelDef<I,O,E>{
      
  //   }
  //}
  //static public function tap<I,O,E>(self:Tu)
}
