package stx.simplex.body;

class Pipes{
  @:noUsing static public function fromArrowlet<I,O>(arw:Arrowlet<I,O>):Pipe<I,O>{
    return Wait(
      Emission.recursive1(arw.apply)
    );
  }
  @:static public function fromEmiterConstrucor<I,O>(cons:I->Emiter<O>):Pipe<I,O>{
    return Wait(
        function(c:Control<I>):Simplex<I,O,Noise>{
          return  c.lift(
            (x:I) -> {
              function recurse(emiter:Emiter<O>):Pipe<I,O>{
                return switch(emiter){
                  case Wait(fn) : Wait(
                    (c:Control<I>) -> c.lift(
                      cons.fn().then(recurse)
                    )
                  );
                  case Emit(head,tail)  : Emit(head,recurse(tail));
                  case Halt(r)          : Halt(r);
                  case Hold(h)          : Hold(h.map(recurse));         
                }
              }
              return recurse(cons(x));
            }
          );
        } 
    );
  }
  static public function fromFunction<I,O>(fn:I->O):Pipe<I,O>{
      var fn0 = fn.fn().catching();
      return Wait(
          function recurse(ctl:Control<I>):Pipe<I,O>{
            return ctl.lift(
              (i:I) ->  switch(fn0(i)){
                  case Failure(e)    : Spx.term(e);
                  case Success(v)    : Spx.emit(v,Spx.wait(recurse));
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
      case Emit(head,tail)  : append(fn(head),flatMap.bind(tail,fn));
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
  static public function always<I,O>(prc:Pipe<I,O>,v:Thunk<I>):Emiter<O>{
    return switch(prc){
      case Emit(head,tail)  : Emit(head,always(tail,v));
      case Hold(ft)         : Hold(ft.map(always.bind(_,v)));
      case Halt(e)          : Halt(e);
      case Wait(fn)         : always(fn(Continue(v())),v);
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
