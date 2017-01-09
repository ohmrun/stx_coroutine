package stx.simplex.pack;

import stx.simplex.core.Data;
import stx.simplex.Package;

import stx.simplex.core.Data.Process in ProcessT;

class Processes{
  /**
    Commits an Error in the production of a Process to an Early; 
  */
  static public function commit<I,O>(p:ProcessT<I,O>):Pipe<I,O>{
    return switch(p){
      case Emit(head,tail)              : Emit(head,commit(tail));
      case Wait(fn)                     : Wait(fn.then(commit));
      case Held(ft)                     : Held(ft.map(commit));
      case Halt(Production(Some(err)))  : Halt(Terminated(Early(err)));
      case Halt(Production(None))       : Halt(Terminated(Finished));
      case Halt(Terminated(cause))      : Halt(Terminated(cause)); 
    }
  }
  static public function append<I,O>(prc0:Process<I,O>,prc1:Thunk<Process<I,O>>):Process<I,O>{
    return switch (prc0){
      case Emit(head,tail)              : Emit(head,append(tail,prc1));
      case Wait(arw)                    : Wait(arw.then(append.bind(_,prc1)));
      case Halt(Terminated(Finished))   : prc1();
      case Halt(Production(None))       : prc1();
      case Halt(Production(Some(err)))  : Halt(Terminated(Early(err)));
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Held(ft)                     : Held(ft.map(append.bind(_,prc1)));
    }
  }
  static public function flatMap<I,O,O2,R>(prc:Process<I,O>,fn:O->Process<I,O2>):Process<I,O2>{
    return switch (prc){
      case Emit(head,tail)  : append(fn(head),Pointwise.toThunk(flatMap(tail,fn)));
      case Wait(arw)        : Wait(
        function(i){
          trace(i);
          var next = arw(i);
          return flatMap(next,fn);
        }
      );
      case Halt(e)          : Halt(e);
      case Held(ft)         : Held(ft.map(flatMap.bind(_,fn)));
    }
  }
  /*
  static public function report<I,O>(p:ProcessT<I,O>):Pipe<I,Outcome<O,Error>>{
    return switch(p){
      case Emit(head,tail)              : Emit(Success(head),commit(tail));
      case Wait(fn)                     : Wait(fn.then(commit));
      case Held(ft)                     : Held(ft.map(commit));
      case Halt(Production(Some(err)))  : Emit(Failure(err),Halt(Terminated(Finished)));
      case Halt(Production(None))       : Halt(Terminated(Finished));
      case Halt(Terminated(cause))      : Halt(Terminated(cause)); 
    }
  }
  
  static public function then<I,O,P>(p0:ProcessT<I,O>,p1:ProcessT<O,P>):Process<I,P>{
    return switch([p0,p1])(
      case Process
    )
  }*/
}
