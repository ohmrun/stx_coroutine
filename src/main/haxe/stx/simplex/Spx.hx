package stx.simplex;

import stx.simplex.core.pack.Cause;
import stx.simplex.core.pack.Simplex;

class Spx{
  static public var STOP = Halt(Production(Noise));

  @:noUsing static public function fail<I,O,R>(er:Error):Simplex<I,O,R>{
    return term(Early(er));
  }
  @:noUsing static public function halt<I,O,R>(ret:Return<R>):Simplex<I,O,R>{
    return Halt(ret);
  }
  @:noUsing static public function term<I,O,R>(cause:Cause):Simplex<I,O,R>{
    return Halt(Terminated(cause));
  }
  @:noUsing static public function stop<I,O,R>():Simplex<I,O,R>{
    return Halt(Terminated(Stop));
  }
  @:noUsing static public function done<I,O,R>(v:R):Simplex<I,O,R>{
    return Halt(Production(v));
  }
  @:noUsing static public function wait<I,O,R>(fn:Emission<I,O,R>):Simplex<I,O,R>{
    return Wait(
        fn
    );
  }
  @:noUsing static public function emit<I,O,R>(head:O,next:Simplex<I,O,R>):Simplex<I,O,R>{
    return Emit(new Emiting(next,head));
  }
  @:noUsing static public function emits<I,O,R>(e:Emiting<I,O,R>):Simplex<I,O,R>{
    return Emit(e);
  }
  @:noUsing static public function hold<I,O,R>(h:Held<I,O,R>):Simplex<I,O,R>{
    return Hold(h);
  }
  @:noUsing static public function seek<I,O,R>(a:Advice,n:Simplex<I,O,R>):Simplex<I,O,R>{
    return Seek(a,n);
  }
}