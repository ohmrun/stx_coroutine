package stx.simplex.pack.source;


import tink.streams.Stream;

//TODO fix Poll logic
class Generate<T> extends Generator<T,Error>{
  public function new(data:Null<Emiter<T>>){
    super(
      (function(){
        var n = Future.trigger();
        function recurse(){
          switch(data){
            case Emit(head,tail):
              data = tail;
              n.trigger(Link(head,new Generate(tail)));
            case Wait(arw):
              data = arw(Noise);
              recurse();
            case Hold(Poll(v)):
              data = v();
              recurse();
            case Hold(Open(v)):
              data = v();
              recurse();
            case Hold(Hung(ft)):
              ft.defer(
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
      })()
    );
  }
}