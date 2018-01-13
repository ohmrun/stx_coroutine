package stx.simplex.body;

class Emiters{
  @:noUsing static public function fromOption<O>(opt:Option<O>):Emiter<O>{
    return Wait(
      function(_){
        return switch(opt){
          case Some(v)  : Emit(v,Halt(Production(Noise)));
          case None     : Halt(Production(Noise));
        }
      }
    );
  }
  @:noUsing static public function fromThunk<O>(thk:Thunk<O>):Emiter<O>{
    return Wait(
      function recurse(ctl:Control<Noise>){
        return Emit(thk(),Wait(recurse));
      }
    );
  }
  /**
   *  Produces a one shot Emiter from any iterable.
   *  Closure created lazily.
   *  @param iter - 
   *  @return Emiter<T>
   */
  @:noUsing static public function fromIterable<T>(iter:Iterable<T>){
    function recurse(it:Iterator<T>,ctl:Control<Noise>):Emiter<T>{
      return switch(ctl){
        case Continue(Noise) :
          return it.hasNext()
            ? {
                var out = it.next();
                //trace('emit $out');
                Emit(out,Wait(recurse.bind(it)));
              }
            : 
              {
                //trace("done");
                Halt(Production(Noise));
              }
        case Discontinue(cause) : Halt(Terminated(cause));         
      }
    }
    return new Emiter(Wait(
      function(ctl:Control<Noise>){
        var itr = iter.iterator();
        return recurse(itr,ctl);
      }
    ));
  }
  static public function fromStream<T>(str:Stream<T>):Emiter<T>{
    return new Emiter(Wait(
      function recurse(_:Control<Noise>):Emiter<T>{
        return Hold(
          new Held(str.next().map(
            function(x:StreamStep<T>):Emiter<T>{
              return switch(x){
                case End      : Halt(Production(Noise));
                case Fail(e)  : Halt(Terminated(Early(stx.Error.fromTinkError(e))));
                case Data(v)  : Emit(v,Wait(recurse));
              };              
            }
          )
        ));
      }
    ));
  }
  static public function reduce<T,U>(source:Emiter<T>,fn:T->U->U,memo:U):Producer<U>{
    return switch(source){
      case Emit(head,tail)                      : reduce(tail,fn,fn(head,memo));
      case Halt(Production(Noise))              : Halt(Production(memo));
      case Halt(Terminated(cause))              : Halt(Terminated(cause));
      case Wait(arw)                            : Wait(arw.then(reduce.bind(_,fn,memo)));
      case Hold(ft)                             : Hold(ft.map(reduce.bind(_,fn,memo)));
    }
  }
  static public function toArray<O>(emt:Emiter<O>):Producer<Array<O>>{
    return reduce(emt,
      (next:O,memo:Array<O>) -> memo.concat([next])
   ,[]);
  }
  static public function flatMap<O,O2>(prc:Emiter<O>,fn:O->Emiter<O2>):Emiter<O2>{
    return switch (prc){
      case Emit(head,tail)  : append(fn(head),Pointwise.toThunk(flatMap(tail,fn)));
      case Wait(arw)        : Wait(
        function(i){
          var next = arw(i);
          return flatMap(next,fn);
        }
      );
      case Halt(e)          : Halt(e);
      case Hold(ft)         : Hold(ft.map(flatMap.bind(_,fn)));
    }
  }
  static public function append<O>(prc0:Emiter<O>,prc1:Thunk<Emiter<O>>):Emiter<O>{
    return switch (prc0){
      case Emit(head,tail)              : Emit(head,append(tail,prc1));
      case Wait(arw)                    : Wait(arw.then(append.bind(_,prc1)));
      case Halt(Production(Noise))      : prc1();
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Hold(ft)                     : Hold(ft.map(append.bind(_,prc1)));
    }
  }
  static public function pipeTo<T>(src:Emiter<T>,fn:T->Void):Future<Option<Error>>{
    var t = Future.trigger();
    function handler(v){
      switch(v){
        case Emit(head,tail)            : fn(head); handler(tail);
        case Wait(fn)                   : handler(fn(Noise));
        case Hold(ft)                   : ft.handle(handler);
        case Halt(Terminated(cause))    : t.trigger(cause.toOption());
        case Halt(Production(Noise))    : t.trigger(None); 
      }
    }
    handler(src);
    return t.asFuture();
  }


  /**
    Pulls on the left when the right is Hold
  **/
  static public function receive<T,U>(self:Emiter<T>,that:Emiter<U>):Emiter<Either<T,U>>{
    return switch([self,that]){
      case [Emit(lhead,ltail),Emit(rhead,rtail)] : Emit(Left(lhead),Emit(Right(rhead),receive(ltail,rtail)));
      case [Wait(larw),Wait(rarw)]               : Wait(
        function(ctrl:Control<Noise>):Simplex<Noise,Either<T,U>,Noise>{
          return ctrl.lift(
            function(_){
              return receive(larw(Continue(Noise)),rarw(Continue(Noise)));
            }
          );
        }
      );
      case [Hold(lft),Hold(rft)]                 :
        Simplex.hold(
          new Held(Util.eitherOrBoth(lft.unwrap(),rft.unwrap()).map(
            function(e){
              return switch(e){
                case Left(Left(l))        : receive(l,Hold(rft)); //always pulls on the left when the right is waiting.
                case Left(Right(r))       : receive(Hold(lft),r);
                case Right(tuple2(l,r))   : receive(l,r);
              }
            }
          ))
        );
      default : Halt(Production(Noise));
    }
  }
  /**
    When the right is Hold, waits for resolution before pulling from the left.
  */
  static public function deliver<T,U>(self:Emiter<T>,that:Emiter<U>):Emiter<Either<T,U>>{
    return switch([self,that]){
      case [Emit(lhead,ltail),Emit(rhead,rtail)] : Emit(Left(lhead),Emit(Right(rhead),deliver(ltail,rtail)));
      case [Wait(larw),Wait(rarw)]               : Wait(
        function(ctrl:Control<Noise>):Simplex<Noise,Either<T,U>,Noise>{
          return ctrl.lift(
            function(_){
              return deliver(larw(Continue(Noise)),rarw(Continue(Noise)));
            }
          );
        }
      );
      case [Hold(lft),Hold(rft)]                 :
        Simplex.hold(
          new Held(Util.eitherOrBoth(lft.unwrap(),rft.unwrap()).flatMap(
            function(e){
              return switch(e){
                case Left(Left(l))        : rft.unwrap().map(
                  deliver.bind(l)
                );
                case Left(Right(r))       : Future.sync(deliver(Hold(lft),r));
                case Right(tuple2(l,r))   : Future.sync(deliver(l,r));
              }
            }
          )
        ));
      default : Halt(Production(Noise));
    }
  }
  static public function search<O>(self:Emiter<O>,prd:O->Bool):Producer<O>{
    return switch(self){
      case Emit(head,tail) if(prd(head))  : Halt(Production(head));
      case Emit(head,tail)                : search(tail,prd);
      case Wait(fn)                       : Wait(fn.then(search.bind(_,prd)));
      case Hold(ft)                       : Hold(ft.map(search.bind(_,prd)));
      case Halt(Production(v))            : Halt(Terminated(Early(Errors.no_value_error())));
      case Halt(Terminated(cause))        : Halt(Terminated(cause));
    }
  }
  static public function first<O>(self:Emiter<O>):Producer<O>{
    return search(self,(v) -> true);
  }
  static public function last<O>(self:Emiter<O>):Producer<O>{
    function recurse(self:Emiter<O>,lst:Option<O>):Producer<O>{
      return switch([self,lst]){
        case [Emit(head,tail),_]                : recurse(tail,Some(head));
        case [Wait(fn),_]                       : Wait(fn.then(recurse.bind(_,lst)));
        case [Hold(ft),_]                       : Hold(ft.map(recurse.bind(_,lst)));
        case [Halt(Production(Noise)),None]     : Halt(Terminated(Early(Errors.no_value_error())));
        case [Halt(Production(Noise)),Some(v)]  : Halt(Production(v));
        case [Halt(Terminated(cause)),_]        : Halt(Terminated(cause));
      }
    }
    return recurse(self,None);
  }
  static public function count<O>(self:Emiter<O>):Producer<Int>{
    return reduce(self,(next,memo) -> memo++,0);
  }
  static public function filter<O>(self:Emiter<O>,prd:O->Bool):Emiter<O>{
    return Sources.filter(self,prd);
  }
  static public function until<O>(self:Emiter<O>,prd:O->Bool):Emiter<O>{
    function recurse(self,cont){
      return switch(self){
        case Wait(fn)         : Wait(fn.then(recurse.bind(_,cont)));
        case Hold(ft)         : Hold(ft.map(recurse.bind(_,cont)));
        case Halt(v)                   : Halt(v);
        case Emit(head,tail)  if(cont) : 
          prd(head) ?
            Emit(head,recurse(tail,true))
          :
            recurse(tail,false);
        case Emit(_,tail)              :
          recurse(tail,false);
      }
    }
    return recurse(self,true);
  }
  static public function take<O>(self:Emiter<O>,max:Int){
    function recurse(self,n){
      return n >= max ? Halt(Production(Noise))
        : switch(self){
          case Wait(fn)         : Wait(fn.then(recurse.bind(_,n)));
          case Hold(ft)         : Hold(ft.map(recurse.bind(_,n)));
          case Halt(out)        : Halt(out);
          case Emit(head,tail)  : Emit(head,recurse(tail,n++));
        }
    }
    return recurse(self,1);
  }
  static public function sink<O>(self:Emiter<O>,next:Sink<O>):Effect{
    function recurse(self,next){
      return switch([self,next]){
        case [Emit(head,tail),Wait(fn)] : recurse(tail,fn(Continue(head)));
        case [Halt(out),_]              : Halt(out);
        case [_,Halt(out)]              : Halt(out);
        case [Wait(fn),_]               : Wait(fn.then(recurse.bind(_,next)));
        case [Hold(ft),_]               : Hold(ft.map(recurse.bind(_,next)));
        case [_,Emit(head,tail)]        : recurse(self,tail);
        case [_,Hold(ft)]               : Hold(ft.map(recurse.bind(self)));
      }
    }
    return recurse(self,next);
  }
  static public function snoc<O>(self:Emiter<O>,o:O):Emiter<O>{
    return switch(self){
      case Halt(Production(Noise))  :
        Emit(o,self);
      case Emit(head,tail)  :
        var op : Emiter<O> = tail; 
        Emit(head,op.snoc(o));
      case Wait(fn)         :
        var op : Emiter<O> = fn(Continue(Noise));  
        op.snoc(o);
      case Hold(ft)         :
        var later  = Held.trigger();
        ft.handle(
          function(next:Emiter<O>){
            var op = snoc(self,o);
            later.trigger(op); 
          }
        );  
        Hold(later.asFuture());
      default : Halt(Production(Noise));
    };
  }
  static public function cons<O>(self:Emiter<O>,v:O):Emiter<O>{
    return Emit(v,self);
  }
}