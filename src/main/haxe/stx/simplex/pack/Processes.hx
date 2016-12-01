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
