package stx.coroutine;

typedef CoroutineSum<I,O,R,E>             = stx.coroutine.core.pack.Coroutine.CoroutineSum<I,O,R,E>; 
typedef Coroutine<I,O,R,E>                = stx.coroutine.core.pack.Coroutine<I,O,R,E>; 
 
typedef ControlSum<I,E>                 = stx.coroutine.core.pack.Control.ControlSum<I,E>;
typedef Control<I,E>                    = stx.coroutine.core.pack.Control<I,E>;
 
typedef CauseSum<E>                     = stx.coroutine.core.pack.Cause.CauseSum<E>;
typedef Cause<E>                        = stx.coroutine.core.pack.Cause<E>;
 
typedef Held<I,O,R,E>                   = stx.coroutine.core.pack.Held<I,O,R,E>;
 
typedef TransmissionDef<I,O,R,E>        = stx.coroutine.core.pack.Transmission.TransmissionDef<I,O,R,E>;
typedef Transmission<I,O,R,E>           = stx.coroutine.core.pack.Transmission<I,O,R,E>;

typedef Phase<I,O,R,E>                  = stx.coroutine.core.pack.Phase<I,O,R,E>;
 
typedef ReturnSum<R,E>                  = stx.coroutine.core.pack.Return.ReturnSum<R,E>;
typedef Return<R,E>                     = stx.coroutine.core.pack.Return<R,E>;

typedef SourceDef<O,R,E>                = stx.coroutine.pack.Source.SourceDef<O,R,E>;   //011
typedef Source<O,R,E>                   = stx.coroutine.pack.Source<O,R,E>;             //011

typedef Emiter<O,E>                     = stx.coroutine.pack.Emiter<O,E>;             //010
typedef Effect<E>                       = stx.coroutine.pack.Effect<E>;                  //000
typedef EffectDef<E>                    = stx.coroutine.pack.Effect.EffectDef<E>;                  //000

typedef ProducerDef<R,E>                = stx.coroutine.pack.Producer.ProducerDef<R,E>;             //001
typedef Producer<R,E>                   = stx.coroutine.pack.Producer<R,E>;             //001


typedef Sink<I,E>                       = stx.coroutine.pack.Sink<I,E>;                 //100
typedef Fold<I,R,E>                     = stx.coroutine.pack.Fold<I,R,E>;               //101
typedef Pipe<I,O,E>                     = stx.coroutine.pack.Pipe<I,O,E>;               //110
//typedef Coroutine<I,O,R,E>      = stx.coroutine.core.Package.Coroutine<I,O,R,E>;  //111

//typedef Tween               = stx.coroutine.pack.Tween;
//typedef Producers           = stx.coroutine.body.Producers;
//typedef Emiters             = stx.coroutine.body.Emiters;
//typedef Folds               = stx.coroutine.body.Folds;
//typedef Reactor<I,O,R,E>      = stx.coroutine.pack.Reactor<I,O,R,E>;
//typedef Arrow<P,I,O,R>      = stx.coroutine.pack.Arrow<P,I,O,R>;
#if sys
  //  typedef Sleep            = stx.coroutine.pack.Sleep;
#end


class LiftCoroutine{
  static public function upcast<I,O,R,E>(wildcard:Wildcard,spx:CoroutineSum<I,O,R,E>):Coroutine<I,O,R,E>{
    return spx;
  }
  // static public function asEmiter<O>(wildcard:Wildcard,spx:Coroutine<Noise,O,Noise>):Emiter<O>{
  //   return new Emiter(spx);
  // }
  // static public function asPipe<I,O>(wildcard:Wildcard,spx:Coroutine<I,O,Noise>):Pipe<I,O>{
  //   return new Pipe(spx);
  // }

  static public function fail<I,O,R,E>(wildcard:Wildcard,er:Err<E>):Coroutine<I,O,R,E>{
    return term(__,Exit(er));
  }
  static public function halt<I,O,R,E>(wildcard:Wildcard,ret:Return<R,E>):Coroutine<I,O,R,E>{
    return Halt(ret);
  }
  static public function term<I,O,R,E>(wildcard:Wildcard,cause:Cause<E>):Coroutine<I,O,R,E>{
    return Halt(Terminated(cause));
  }
  static public function stop<I,O,R,E>(wildcard:Wildcard):Coroutine<I,O,R,E>{
    return Halt(Terminated(Stop));
  }
  static public function done<I,O,R,E>(wildcard:Wildcard,v:R):Coroutine<I,O,R,E>{
    return Halt(Production(v));
  }
  static public function wait<I,O,R,E>(wildcard:Wildcard,fn:Transmission<I,O,R,E>):Coroutine<I,O,R,E>{
    return Wait(fn);
  }
  static public function emit<I,O,R,E>(wildcard:Wildcard,head:O,next:CoroutineSum<I,O,R,E>):Coroutine<I,O,R,E>{
    return Emit(head,next);
  }
  static public function hold<I,O,R,E>(wildcard:Wildcard,h:Held<I,O,R,E>):Coroutine<I,O,R,E>{
    return Hold(h);
  }
  static public function lazy<I,O,R,E>(wildcard:Wildcard,self:Void->Coroutine<I,O,R,E>):Coroutine<I,O,R,E>{
    return Held.lazy(self);
  }
  static public function into<I,O,Oi,R,Ri,E>(wildcard:Wildcard,fn:CoroutineSum<I,O,R,E>->CoroutineSum<I,Oi,Ri,E>):Coroutine<I,O,R,E>->Coroutine<I,Oi,Ri,E>{
    return Transmission.into(fn);
  }
}