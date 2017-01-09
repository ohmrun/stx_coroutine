package stx.simplex.pack;

import stx.Tuple;
import tink.core.Either;
import tink.core.Future;
import haxe.ds.Option;

class Util{
  static public function getOption<T>(ft:Future<T>):Option<T>{
    var cancelled = false;
    var val       = None;
    var canceller = ft.handle(
      function(x:T){
        if(!cancelled){
          cancelled = true;
          val       = Some(x);
        }
      }
    );
    return val;
  }
  @:noUsing static public function either<L,R>(lhs:Future<L>,rhs:Future<R>,?right:Bool = false):Future<Either<L,R>>{
    var t       = Future.trigger();

    var lopt    = getOption(lhs);
    var ropt    = getOption(rhs);

    switch([lopt,ropt]){
      case [Some(l),Some(r)]  : right ? t.trigger(Right(r)) : t.trigger(Left(l));
      case [Some(l),None]     : t.trigger(Left(l));
      case [None,Some(r)]     : t.trigger(Right(r));
      case [None,None]        :
        var cancelled = false;
        var val       = None;
        var l_cancel : CallbackLink = null;
        var r_cancel : CallbackLink = null;

        var starter_l : Void -> CallbackLink = lhs.handle.bind(
          function(x:L){
            r_cancel.dissolve();
            if(!cancelled){
              cancelled = true;
              t.trigger(Left(x));
            }
          }
        );  
        var starter_r : Void -> CallbackLink= rhs.handle.bind(
          function(x:R){
            l_cancel.dissolve();
            if(!cancelled){
              cancelled = true;
              t.trigger(Right(x));
            }
          }
        );  
        if(!right){
          l_cancel = starter_l();
          r_cancel = starter_r();
        }else{
          r_cancel = starter_r();
          l_cancel = starter_l();
        }
    }
    return t.asFuture();
  }
  static public function eitherOrBoth<L,R>(lhs:Future<L>,rhs:Future<R>):Future<Either<Either<L,R>,Tuple2<L,R>>>{
    var t       = Future.trigger();

    var lopt    = getOption(lhs);
    var ropt    = getOption(rhs);

    switch([lopt,ropt]){
      case [Some(l),Some(r)]  : t.trigger(Right(tuple2(l,r)));
      case [Some(l),None]     : t.trigger(Left(Left(l)));
      case [None,Some(r)]     : t.trigger(Left(Right(r)));
      case [None,None]        :
        var cancelled = false;
        var val       = None;
        var l_cancel, r_cancel : CallbackLink = null;
        l_cancel = lhs.handle(
          function(x:L){
            r_cancel.dissolve();
            if(!cancelled){
              cancelled = true;
              t.trigger(Left(Left(x)));
            }
          }
        );  
        rhs.handle(
          function(x:R){
            l_cancel.dissolve();
            if(!cancelled){
              cancelled = true;
              t.trigger(Left(Right(x)));
            }
          }
        );  
    }
    return t.asFuture();
  }
}