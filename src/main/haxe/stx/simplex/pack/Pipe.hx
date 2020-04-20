package stx.simplex.pack;

typedef PipeDef<I,O,E> = Interface<I,O,Noise,E>;

import stx.simplex.body.Pipes;
import stx.simplex.core.body.Simplexs;

@:forward abstract Pipe<I,O,E>(PipeT<I,O,E>) from PipeT<I,O,E> to PipeT<I,O,E>{
  public function new(self){
    this = self;
  }
  @:from @:noUsing static public function fromFunction<I,O,E>(fn:I->O):Pipe<I,O,E>{
    return Pipes.fromFunction(fn);
  }
  @:from @:noUsing static public function fromArrowlet<I,O,E>(fn:Arrowlet<I,O,E>):Pipe<I,O,E>{
    return Pipes.fromArrowlet(fn);
  }
  public function flatMap<O2>(fn:O->Pipe<I,O2>):Pipe<I,O2>{
    return Pipes.flatMap(this,fn);
  }
  public function append(that):Pipe<I,O,E>{
    return Pipes.append(this,that);
  }
  public function fill(str):Emiter<O>{
    return Simplexs.fill(this,str).asEmiter();
  }
  public function always(v:Thunk<I>):Emiter<O>{
    return Pipes.always(this,v);
  }
}
class Pipes{
  @:noUsing static public function fromArrowlet<I,O,E>(arw:Arrowlet<I,O,E>):Pipe<I,O,E>{
    return Wait(
      Emission.recursive1(arw.apply)
    );
  }
  @:static public function fromEmiterConstrucor<I,O,E>(cons:I->Emiter<O>):Pipe<I,O,E>{
    return Wait(
        function(c:Control<I>):Simplex<I,O,Noise>{
          return  c.lift(
            (x:I) -> {
              function recurse(emiter:Emiter<O>):Pipe<I,O,E>{
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
  static public function fromFunction<I,O,E>(fn:I->O):Pipe<I,O,E>{
      var fn0 = fn.fn().catching();
      return Wait(
          function recurse(ctl:Control<I>):Pipe<I,O,E>{
            return ctl.lift(
              (i:I) ->  switch(fn0(i)){
                  case Failure(e)    : __.term(e);
                  case Success(v)    : __.emit(v,__.wait(recurse));
              }
            );
          }
      );
  }
  static public function append<I,O,E>(prc0:Pipe<I,O,E>,prc1:Thunk<Pipe<I,O,E>>):Pipe<I,O,E>{
    return switch (prc0){
      case Emit(head,tail)              : Emit(head,append(tail,prc1));
      case Wait(arw)                    : Wait(arw.then(append.bind(_,prc1)));
      case Halt(Production(Noise))      : prc1();
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Hold(ft)                     : Hold(ft.map(append.bind(_,prc1)));
    }
  }
  static public function flatMap<I,O,O2,R>(prc:Pipe<I,O,E>,fn:O->Pipe<I,O2>):Pipe<I,O2>{
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
  static public function always<I,O,E>(prc:Pipe<I,O,E>,v:Thunk<I>):Emiter<O>{
    return switch(prc){
      case Emit(head,tail)  : Emit(head,always(tail,v));
      case Hold(ft)         : Hold(ft.map(always.bind(_,v)));
      case Halt(e)          : Halt(e);
      case Wait(fn)         : always(fn(Continue(v())),v);
    }
  }
  /*
  static public function report<I,O,E>(p:PipeT<I,O,E>):Pipe<I,Outcome<O,Error>>{
    return switch(p){
      case Emit(head,tail)              : Emit(Success(head),commit(tail));
      case Wait(fn)                     : Wait(fn.then(commit));
      case Hold(ft)                     : Hold(ft.map(commit));
      case Halt(Production(Some(err)))  : Emit(Failure(err),Halt(Terminated(Finished)));
      case Halt(Production(None))       : Halt(Terminated(Finished));
      case Halt(Terminated(cause))      : Halt(Terminated(cause)); 
    }
  }
  
  static public function then<I,O,P>(p0:PipeT<I,O,E>,p1:PipeT<O,P>):Pipe<I,P>{
    return switch([p0,p1])(
      case Pipe
    )
  }*/
}
