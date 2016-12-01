package stx.simplex.pack;

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
}