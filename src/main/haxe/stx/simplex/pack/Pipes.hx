package stx.simplex.pack;

import stx.simplex.core.Data;

class Pipes{
  static public function flatMap<I,O,O2,R>(prc:Pipe<I,O>,fn:O->Pipe<I,O2>):Pipe<I,O2>{
    return switch (prc){
      case Emit(head,tail)  : append(fn(head),Pointwise.toThunk(flatMap(tail,fn)));
      case Wait(arw)        : Wait(
        function(i){
          var next = arw(i);
          return flatMap(next,fn);
        }
      );
      case Halt(e)          : Halt(e);
      case Held(ft)         : Held(ft.map(flatMap.bind(_,fn)));
    }
  }
  static public function append<I,O>(prc0:Pipe<I,O>,prc1:Thunk<Pipe<I,O>>):Pipe<I,O>{
    return switch (prc0){
      case Emit(head,tail)              : Emit(head,append(tail,prc1));
      case Wait(arw)                    : Wait(arw.then(append.bind(_,prc1)));
      case Halt(Terminated(Finished))   : prc1();
      case Halt(Production(Noise))      : prc1();
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Held(ft)                     : Held(ft.map(append.bind(_,prc1)));
    }
  }
}