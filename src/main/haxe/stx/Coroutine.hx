package stx;

using stx.Nano;
using stx.Fail;
using stx.coroutine.Core;
using stx.Coroutine;
// typedef CoroutineFailureSum<E>          = stx.fail.CoroutineFailure.CoroutineFailureSum<E>;
// typedef CoroutineFailure<E>             = stx.fail.CoroutineFailure<E>;

typedef CoroutineFailureNote            = stx.fail.CoroutineFailureNote;

typedef Effect<E>                       = stx.coroutine.pack.Effect<E>;                               //000 
typedef EffectDef<E>                    = stx.coroutine.pack.Effect.EffectDef<E>;                     //000

typedef DeriveDef<R,E>                  = stx.coroutine.pack.Derive.DeriveDef<R,E>;                   //001
typedef Derive<R,E>                     = stx.coroutine.pack.Derive<R,E>;                             //001

typedef Emiter<O,E>                     = stx.coroutine.pack.Emiter<O,E>;                             //010

typedef SourceDef<O,R,E>                = stx.coroutine.pack.Source.SourceDef<O,R,E>;                 //011
typedef Source<O,R,E>                   = stx.coroutine.pack.Source<O,R,E>;                           //011

typedef Secure<I,E>                     = stx.coroutine.pack.Secure<I,E>;                             //100

typedef Relate<I,R,E>                   = stx.coroutine.pack.Relate<I,R,E>;                           //101
typedef RelateDef<I,O,E>                = stx.coroutine.pack.Relate.RelateDef<I,O,E>;                 //110

typedef Tunnel<I,O,E>                   = stx.coroutine.pack.Tunnel<I,O,E>;                           //110
typedef TunnelDef<I,O,E>                = stx.coroutine.pack.Tunnel.TunnelDef<I,O,E>;                 //110

typedef CoroutineSum<I,O,R,E>           = stx.coroutine.core.Coroutine.CoroutineSum<I,O,R,E>;         //111
typedef Coroutine<I,O,R,E>              = stx.coroutine.core.Coroutine<I,O,R,E>;                      //111

typedef TransmissionDef<I,O,R,E>        = stx.coroutine.core.Transmission.TransmissionDef<I,O,R,E>;
typedef Transmission<I,O,R,E>           = stx.coroutine.core.Transmission<I,O,R,E>;

class LiftCoroutine{
  static public function e_coroutine(digests:Digests,note:CoroutineFailureNote){
    return new stx.coroutine.core.Digest(note);
  }
  static public inline function upcast<I,O,R,E>(wildcard:Wildcard,spx:CoroutineSum<I,O,R,E>):Coroutine<I,O,R,E>{
    return spx;
  }
  // static public function asEmiter<O>(wildcard:Wildcard,spx:Coroutine<Noise,O,Noise>):Emiter<O>{
  //   return new Emiter(spx);
  // }
  // static public function asTunnel<I,O>(wildcard:Wildcard,spx:Coroutine<I,O,Noise>):Tunnel<I,O>{
  //   return new Tunnel(spx);
  // }
  static public inline function quit<I,O,R,E>(wildcard:Wildcard,er:Refuse<E>):Coroutine<I,O,R,E>{
    return term(__,Exit(er));
  }
  static public inline function exit<I,O,R,E>(wildcard:Wildcard,er:Refuse<E>):Coroutine<I,O,R,E>{
    return term(__,Exit(er));
  }
  static public inline function halt<I,O,R,E>(wildcard:Wildcard,ret:Return<R,E>):Coroutine<I,O,R,E>{
    return Halt(ret);
  }
  static public inline function term<I,O,R,E>(wildcard:Wildcard,cause:Cause<E>):Coroutine<I,O,R,E>{
    return Halt(Terminated(cause));
  }
  static public inline function stop<I,O,R,E>(wildcard:Wildcard):Coroutine<I,O,R,E>{
    return Halt(Terminated(Stop));
  }
  static public inline function prod<I,O,R,E>(wildcard:Wildcard,v:R):Coroutine<I,O,R,E>{
    return Halt(Production(v));
  }
  static public inline function wait<I,O,R,E>(wildcard:Wildcard,fn:Transmission<I,O,R,E>):Coroutine<I,O,R,E>{
    return Wait(fn);
  }
  static public inline function emit<I,O,R,E>(wildcard:Wildcard,head:O,next:CoroutineSum<I,O,R,E>):Coroutine<I,O,R,E>{
    return Emit(head,next);
  }
  static public inline function hold<I,O,R,E>(wildcard:Wildcard,h:Held<I,O,R,E>):Coroutine<I,O,R,E>{
    return Hold(h);
  }
  static public inline function lazy<I,O,R,E>(wildcard:Wildcard,self:Void->Coroutine<I,O,R,E>):Coroutine<I,O,R,E>{
    return Held.lazy(self);
  }
  static public inline function into<I,O,Oi,R,Ri,E>(wildcard:Wildcard,fn:CoroutineSum<I,O,R,E>->CoroutineSum<I,Oi,Ri,E>):Coroutine<I,O,R,E>->Coroutine<I,Oi,Ri,E>{
    return Transmission.into(fn);
  }
  static public inline function tran<I,O,R,E>(wildcard:Wildcard,fn:I->CoroutineSum<I,O,R,E>):Coroutine<I,O,R,E>{
    return __.wait(Transmission.fromFun1R(fn));
  }
  static public function coroutine(wildcard:Wildcard){
    return new stx.coroutine.Module();
  }
}
class LiftSource{
  
}
typedef LiftIterable    = stx.coroutine.lift.LiftIterable;
//typedef LiftThunk       = stx.coroutine.lift.LiftThunk;
typedef LiftOption      = stx.coroutine.lift.LiftOption;
typedef LiftArrowlet    = stx.coroutine.lift.LiftArrowlet;
typedef LiftFun         = stx.coroutine.lift.LiftFun;