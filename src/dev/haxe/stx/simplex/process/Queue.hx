package stx.process;

import stx.types.Process;

enum QueueOp<T>{
  Enque(v:T);
  Deque;
}
class MemoryQueue{
  static public function value<T>(){
    var stack = [];
    return Wait(
      function queue(q:QueueOp<T>,cont){
        switch (q) {
          case Enque(v) : 
            stack.unshift(v);
            cont(Wait(queue));
          case Deque  :
            var o = stack.pop();
            if(o == null && stack.length == 0){
              cont(Halt(null));
            }else{
              cont(Emit(o,Wait(queue)));
            }
        }
      }
    );
  }
}