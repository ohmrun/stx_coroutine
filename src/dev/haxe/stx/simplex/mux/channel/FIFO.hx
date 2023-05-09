package stx.coroutine.pack.channel;

import stx.coroutine.core.data.Channel in ChannelT;

abstract FIFO<T>(ChannelT<T>) from ChannelT<T> to ChannelT<T>{
  static public function unit<T>():FIFO<T>{
    return Wait(
      function recurse(stack:ReadonlyArray<T>,ch:Control<ChannelOp<T>>){
        return ch.lift(
          function(x:ChannelOp<T>){
            return switch(x){
              case Push(v)  : 
                Wait(recurse.bind(stack.append(v)));
              case Pull     :
                if(stack.length == 0){
                  Halt(Terminated(Finished));
                }else{
                  var val = stack.head();
                  Emit(val,Wait(recurse.bind(stack.tail())));
                }
            }
          }
        );
      }.bind([])
    );
  }
  public function new(self){
    this = self;
  }
  public function push(i:T):FIFO<T>{
    return new FIFO(Coroutines.push(this,Push(i)));
  }
  /*
  public function pull():Tuple2<Future<Option<T>>,FIFO<T>>{

  }*/
  public function toSource():Source<T>{
      var commit = Processes.commit;
      var out = Wait(
          function recurse(ctrl:Control<Nada>){
            return switch(ctrl){
              case Continue(Nada) :
                function handler(channel:FIFO<T>){
                  return switch(channel){
                    case Wait(fn)         : handler(fn(Continue(Pull)));
                    case Emit(head,tail)  : Emit(head,handler(tail));
                    case Halt(cause)      : Halt(cause);  
                    case Hold(ft)         : Hold(ft.map(handler));
                  }
                }
                handler(this);
              case Discontinue(cause) : Halt(Terminated(cause)); 
            }
          }
        ).commit();
      return new Source(out);
  }
}