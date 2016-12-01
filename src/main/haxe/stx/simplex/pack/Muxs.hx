package stx.simplex.pack;

import tink.core.Either;

import stx.simplex.core.Data;
using stx.simplex.Package;

class Muxs{
  static public function then<L,R>(sel0:Mux<L,R>,sel1:Mux<L,R>):Mux<L,R>{
    return sel0.flatMapR(
      function(_:Noise){
        return sel1;
      }
    );
  }
  @:noUsing static public function whilst<L,R>(fn:Either<L,R>->Bool):Mux<L,R>{
    return Wait(
      function recurse(ctrl){
        return ctrl.lift(
          function(either){
            return fn(either) ? Emit(Keep,Wait(recurse)) : Halt(Terminated(Finished));  
          }
        );
      }
    );
  }
  @:noUsing static public function once<L,R>(fn:Either<L,R>->Bool):Mux<L,R>{
    return Wait(
      function(ctrl){
        return ctrl.lift(
          function(either){
            return fn(either) ? Emit(Keep,Halt(Terminated(Finished))) : Halt(Terminated(Finished));
          }
        );
      }
    );
  }
  @:noUsing static public function left<L,R>(fn:L->Bool):Mux<L,R>{
    return once(
      function(either){
        return switch(either){
          case Left(v) : fn(v);
          default      : false;
        }
      }
    );
  }
  @:noUsing static public function right<L,R>(fn:R->Bool):Mux<L,R>{
    return once(
      function(either){
        return switch(either){
          case Right(v) : fn(v);
          default       : false;
        }
      }
    );
  } 
}
