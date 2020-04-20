package stx.simplex;

typedef SimplexDef<I,O,R,E>             = stx.simplex.core.pack.Simplex.SimplexDef<I,O,R,E>; 
typedef Simplex<I,O,R,E>                = stx.simplex.core.pack.Simplex<I,O,R,E>; 
 
typedef ControlSum<I,E>                 = stx.simplex.core.pack.Control.ControlSum<I,E>;
typedef Control<I,E>                    = stx.simplex.core.pack.Control<I,E>;
 
typedef CauseSum<E>                     = stx.simplex.core.pack.Cause.CauseSum<E>;
typedef Cause<E>                        = stx.simplex.core.pack.Cause<E>;
 
typedef Held<I,O,R,E>                   = stx.simplex.core.pack.Held<I,O,R,E>;
 
typedef TransmissionDef<I,O,R,E>        = stx.simplex.core.pack.Transmission.TransmissionDef<I,O,R,E>;
typedef Transmission<I,O,R,E>           = stx.simplex.core.pack.Transmission<I,O,R,E>;

typedef Phase<I,O,R,E>                  = stx.simplex.core.pack.Phase<I,O,R,E>;
 
typedef ReturnSum<R,E>                  = stx.simplex.core.pack.Return.ReturnSum<R,E>;
typedef Return<R,E>                     = stx.simplex.core.pack.Return<R,E>;

typedef SourceDef<O,R,E>                = stx.simplex.pack.Source.SourceDef<O,R,E>;   //011
typedef Source<O,R,E>                   = stx.simplex.pack.Source<O,R,E>;             //011

//typedef Emiter<O,E>                     = stx.simplex.pack.Emiter<O,E>;             //010
typedef Effect<E>                       = stx.simplex.pack.Effect<E>;                  //000
// typedef Producer<R>         = stx.simplex.pack.Producer<R>;             //001


// typedef Sink<I>             = stx.simplex.pack.Sink<I>;                 //100
// typedef Fold<I,R>           = stx.simplex.pack.Fold<I,R>;               //101
//typedef Pipe<I,O>           = stx.simplex.pack.Pipe<I,O>;               //110
//typedef Simplex<I,O,R,E>      = stx.simplex.core.Package.Simplex<I,O,R,E>;  //111

//typedef Tween               = stx.simplex.pack.Tween;
//typedef Producers           = stx.simplex.body.Producers;
//typedef Emiters             = stx.simplex.body.Emiters;
//typedef Folds               = stx.simplex.body.Folds;
//typedef Reactor<I,O,R,E>      = stx.simplex.pack.Reactor<I,O,R,E>;
//typedef Arrow<P,I,O,R>      = stx.simplex.pack.Arrow<P,I,O,R>;
#if sys
  //  typedef Sleep            = stx.simplex.pack.Sleep;
#end


class LiftSimplex{
  static public function upcast<I,O,R,E>(wildcard:Wildcard,spx:SimplexDef<I,O,R,E>):Simplex<I,O,R,E>{
    return spx;
  }
  // static public function asEmiter<O>(wildcard:Wildcard,spx:Simplex<Noise,O,Noise>):Emiter<O>{
  //   return new Emiter(spx);
  // }
  // static public function asPipe<I,O>(wildcard:Wildcard,spx:Simplex<I,O,Noise>):Pipe<I,O>{
  //   return new Pipe(spx);
  // }

  static public function fail<I,O,R,E>(wildcard:Wildcard,er:Err<E>):Simplex<I,O,R,E>{
    return term(__,Exit(er));
  }
  static public function halt<I,O,R,E>(wildcard:Wildcard,ret:Return<R,E>):Simplex<I,O,R,E>{
    return Halt(ret);
  }
  static public function term<I,O,R,E>(wildcard:Wildcard,cause:Cause<E>):Simplex<I,O,R,E>{
    return Halt(Terminated(cause));
  }
  static public function stop<I,O,R,E>(wildcard:Wildcard):Simplex<I,O,R,E>{
    return Halt(Terminated(Stop));
  }
  static public function done<I,O,R,E>(wildcard:Wildcard,v:R):Simplex<I,O,R,E>{
    return Halt(Production(v));
  }
  static public function wait<I,O,R,E>(wildcard:Wildcard,fn:Transmission<I,O,R,E>):Simplex<I,O,R,E>{
    return Wait(fn);
  }
  static public function emit<I,O,R,E>(wildcard:Wildcard,head:O,next:SimplexDef<I,O,R,E>):Simplex<I,O,R,E>{
    return Emit(head,next);
  }
  static public function hold<I,O,R,E>(wildcard:Wildcard,h:Held<I,O,R,E>):Simplex<I,O,R,E>{
    return Hold(h);
  }
  static public function lazy<I,O,R,E>(wildcard:Wildcard,self:Void->Simplex<I,O,R,E>):Simplex<I,O,R,E>{
    return Held.lazy(self);
  }
}