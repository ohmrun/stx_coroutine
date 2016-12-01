package stx.simplex.pack;

import stx.simplex.core.Data;
using stx.simplex.pack.Simplex;
import tink.core.Either;


typedef MuxT<L,R> = Simplex<Either<L,R>,Muxer,Noise>;

@:forward abstract Mux<L,R>(MuxT<L,R>) from MuxT<L,R> to MuxT<L,R>{
  public function new(self){
    this = self;
  }
  static public function pure<L,R>(sel:Muxer):Mux<L,R>{
    return Emit(sel,Halt(Terminated(Finished)));
  }
  public function then(sel1:Mux<L,R>){
    return Muxs.then(this,sel1);
  }
}