package stx.process.types;

import stx.pico.Nada;
import stx.types.Process;

class Producer{
  static public function unit<A>():stx.types.Producer<A>{
    return Wait(function(x,cont) cont(Halt(null)));
  }
}