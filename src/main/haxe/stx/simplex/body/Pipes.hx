package stx.simplex.body;

class Pipes{
  @:noUsing static public function fromArrowlet<I,O>(arw:Arrowlet<I,O>):Pipe<I,O>{
    return Wait(
      Emission.recursive1(arw.apply)
    );
  }
  static public function fromFunction<I,O>(fn:I->O):Pipe<I,O>{
      var fn0 = fn.catching();
      return Wait(
          function recurse(ctl:Control<I>):Pipe<I,O>{
            return ctl.lift(
              (i:I) ->  switch(fn0(i)){
                  case Failure(e)    : Halt(Terminated(Early(stx.Error.fromTinkError(e))));
                  case Success(v)    : Emit(v,Wait(recurse));
              }
            );
          }
      );
  }
  static public function append<I,O>(prc0:Pipe<I,O>,prc1:Thunk<Pipe<I,O>>):Pipe<I,O>{
    return switch (prc0){
      case Emit(head,tail)              : Emit(head,append(tail,prc1));
      case Wait(arw)                    : Wait(arw.then(append.bind(_,prc1)));
      case Halt(Production(Noise))      : prc1();
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Hold(ft)                     : Hold(ft.map(append.bind(_,prc1)));
    }
  }
  static public function flatMap<I,O,O2,R>(prc:Pipe<I,O>,fn:O->Pipe<I,O2>):Pipe<I,O2>{
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
      case Hold(ft)         : Hold(ft.map(flatMap.bind(_,fn)));
    }
  }
  /*
  static public function report<I,O>(p:PipeT<I,O>):Pipe<I,Outcome<O,Error>>{
    return switch(p){
      case Emit(head,tail)              : Emit(Success(head),commit(tail));
      case Wait(fn)                     : Wait(fn.then(commit));
      case Hold(ft)                     : Hold(ft.map(commit));
      case Halt(Production(Some(err)))  : Emit(Failure(err),Halt(Terminated(Finished)));
      case Halt(Production(None))       : Halt(Terminated(Finished));
      case Halt(Terminated(cause))      : Halt(Terminated(cause)); 
    }
  }
  
  static public function then<I,O,P>(p0:PipeT<I,O>,p1:PipeT<O,P>):Pipe<I,P>{
    return switch([p0,p1])(
      case Pipe
    )
  }*/
}
