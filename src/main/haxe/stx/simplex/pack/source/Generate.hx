package stx.simplex.pack.source;

import tink.streams.StreamStep;
import tink.streams.Stream;
import tink.streams.Accumulator;

class Generate<T> extends Generator<T>{
  public function new(data:Null<Emiter<T>>){
    super(
      function(){
        var n = Future.trigger();
        function recurse(){
          switch(data){
            case Emit(head,tail):
              data = tail;
              n.trigger(Data(head));
            case Wait(arw):
              data = arw(Noise);
              recurse();
            case Hold(ft):
              ft.handle(
                function(x){
                  data = x;
                  recurse();
                }
              );
            case Halt(e):
              data = Halt(e);
              n.trigger(End);
            case null : 
              n.trigger(End);
          }
        }
        recurse();
        return n.asFuture();
      }
    );
  }
}