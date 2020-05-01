package stx.coroutine.pack;

import tink.core.Either;

import stx.coroutine.core.Data;
using stx.coroutine.Package;

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
            return fn(either) ? Emit(ChooseEither,Wait(recurse)) : Halt(Terminated(Finished));  
          }
        );
      }
    );
  }
  @:noUsing static public function on<L,R>(fn:Either<L,R>->Bool,selector:Muxer):Mux<L,R>{
    return Wait(
      function(ctrl){
        return ctrl.lift(
          function(either){
            return fn(either) ? Emit(selector,Halt(Terminated(Finished))) : Halt(Terminated(Finished));
          }
        );
      }
    ); 
  }
  @:noUsing static public function once<L,R>(fn:Either<L,R>->Bool):Mux<L,R>{
    return on(fn,ChooseEither);
  }
  @:noUsing static public function until<L,R>(fn:Either<L,R>->Bool,selector:Muxer):Mux<L,R>{
    return Wait(
      function recurse(ctl:Control<Either<L,R>>):Mux<L,R>{
        return switch(ctl){
          case Continue(ipt)      : fn(ipt) ? Emit(selector,Wait(recurse)) : Halt(Terminated(Finished));
          case Discontinue(ipt)   : Halt(ipt);
        }  
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
