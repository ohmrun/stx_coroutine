package stx.simplex.body;


import haxe.PosInfos;

class Emiters{
  @:noUsing static public function fromOption<O>(opt:Option<O>):Emiter<O>{
    return Held.lazy(
      () -> switch (opt){
        case None     : Spx.stop();
        case Some(v)  : Spx.stop().cons(v); 
      }
    );
  }
  @:noUsing static public function fromThunk<O>(thk:Thunk<O>):Emiter<O>{
    return Held.lazy(
      function recurse(){
        return Held.lazy(recurse).cons(thk());
      }
    );
  }
  @:noUsing static public function fromIterator<T>(iter:Iterator<T>){
    return Held.lazy(
      function recurse(){
        return switch(iter.hasNext()){
          case true   : Held.lazy(recurse).cons(iter.next());
          case false  : Spx.stop(); 
        }
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
    return Held.lazy(
      () -> fromIterator(iter.iterator())
    );
  }
  static public function reduce<T,U>(source:Emiter<T>,fn:T->U->U,memo:U):Producer<U>{
    function f(source:Emiter<T>,memo) { return reduce(source,fn,memo); }
    function c(memo){ return f.bind(_,memo); } 
    return switch(source.state){
      case Emit(emit)                           : f(emit.next,fn(emit.data,memo));
      case Halt(Production(Noise))              : Spx.done(memo);
      case Halt(Terminated(cause))              : Spx.term(cause);
      case Wait(arw)                            : Spx.wait(arw.mod(c(memo)));
      case Hold(ft)                             : Spx.held(ft.mod(c(memo)));
      case Seek(a,n)                            : Spx.seek(a,n.mod(f));
    }
  }
  static public function toArray<O>(emt:Emiter<O>):Producer<Array<O>>{
    return reduce(emt,
      (next:O,memo:Array<O>) -> memo.concat([next])
   ,[]);
  }
  static public function flatMap<O,O2>(prc:Emiter<O>,fn:O->Emiter<O2>):Emiter<O2>{
    function f(prc) return flatMap(prc,fn);
    return switch (prc.state){
      case Emit(emit)       : append(fn(emit.data),f.bind(emit.next));
      case Wait(arw)        : Spx.wait(arw.mod(f));
      case Halt(e)          : Spx.done(e);
      case Hold(ft)         : Spx.held(ft.mod(f));
    }
  }
  static public function append<O>(prc0:Emiter<O>,prc1:Thunk<Emiter<O>>):Emiter<O>{
    function f(prc0) return append(prc0,prc1);
    return switch (prc0.state){
      case Emit(emit)                   : Spx.emit(emit.mod(f));
      case Wait(arw)                    : Spx.wait(arw.mod(f));
      case Halt(Production(Noise))      : prc1();
      case Halt(Terminated(cause))      : Spx.term(cause);
      case Hold(ft)                     : Spx.held(ft.mod(f));
    }
  }
  /**
    Pulls on the left when the right is Hold
  **/
  // static public function receive<T,U>(self:Emiter<T>,that:Emiter<U>):Emiter<Either<T,U>>{
  //   return switch([self,that]){
  //     case [Emit(lhead,ltail),Emit(rhead,rtail)] : Emit(Left(lhead),Emit(Right(rhead),receive(ltail,rtail)));
  //     case [Wait(larw),Wait(rarw)]               : Wait(
  //       function(ctrl:Control<Noise>):Simplex<Noise,Either<T,U>,Noise>{
  //         return ctrl.lift(
  //           function(_){
  //             return receive(larw(Continue(Noise)),rarw(Continue(Noise)));
  //           }
  //         );
  //       }
  //     );
  //     case [Hold(lft),Hold(rft)]                 :
  //       Simplex.hold(
  //         Util.eitherOrBoth(lft.unwrap(),rft.unwrap()).map(
  //           function(e){
  //             return switch(e){
  //               case Left(Left(l))        : receive(l,Hold(rft)); //always pulls on the left when the right is waiting.
  //               case Left(Right(r))       : receive(Hold(lft),r);
  //               case Right(tuple2(l,r))   : receive(l,r);
  //             }
  //           }
  //         )
  //       );
  //     default : Halt(Production(Noise));
  //   }
  // }
  // /**
  //   When the right is Hold, waits for resolution before pulling from the left.
  // */
  // static public function deliver<T,U>(self:Emiter<T>,that:Emiter<U>):Emiter<Either<T,U>>{
  //   return switch([self,that]){
  //     case [Emit(lhead,ltail),Emit(rhead,rtail)] : Emit(Left(lhead),Emit(Right(rhead),deliver(ltail,rtail)));
  //     case [Wait(larw),Wait(rarw)]               : Wait(
  //       function(ctrl:Control<Noise>):Simplex<Noise,Either<T,U>,Noise>{
  //         return ctrl.lift(
  //           function(_){
  //             return deliver(larw(Continue(Noise)),rarw(Continue(Noise)));
  //           }
  //         );
  //       }
  //     );
  //     case [Hold(lft),Hold(rft)]                 :
  //       Simplex.hold(
  //         new Held(Util.eitherOrBoth(lft.unwrap(),rft.unwrap()).flatMap(
  //           function(e){
  //             return switch(e){
  //               case Left(Left(l))        : rft.unwrap().map(
  //                 deliver.bind(l)
  //               );
  //               case Left(Right(r))       : Future.sync(deliver(Hold(lft),r));
  //               case Right(tuple2(l,r))   : Future.sync(deliver(l,r));
  //             }
  //           }
  //         )
  //       ));
  //     default : Halt(Production(Noise));
  //   }
  // }
  static public function search<O>(self:Emiter<O>,prd:O->Bool):Producer<O>{
    function f(self){ return search(self,prd); }
    return switch(self){
      case Emit(emit)     if(prd(emit.data))  : Spx.done(emit.data);
      case Emit(emit)                         : search(emit.next,prd);
      case Wait(fn)                           : Spx.wait(fn.then(f));
      case Hold(ft)                           : ft.map(f);
      case Halt(Production(v))                : Errors.no_value_error();
      case Halt(Terminated(cause))            : cause;
    }
  }
  static public function first<O>(self:Emiter<O>):Producer<O>{
    return search(self,(v) -> true);
  }
  static public function last<O>(self:Emiter<O>):Producer<O>{
    function recurse(self:Emiter<O>,lst:Option<O>):Producer<O>{
      function f(self){
        return recurse(self,lst);
      }
      return switch([self,lst]){
        case [Emit(emit),_]                     : recurse(emit.next,Some(emit.data));
        case [Wait(fn),_]                       : Wait(fn.then(f));
        case [Hold(ft),_]                       : ft.map(f);
        case [Halt(Production(Noise)),None]     : Errors.no_value_error();
        case [Halt(Production(Noise)),Some(v)]  : Spx.done(v);
        case [Halt(Terminated(cause)),_]        : cause;
      }
    }
    return recurse(self,None);
  }
  static public function at<O>(self:Emiter<O>,index:Int):Producer<O>{
    function recurse(self:Emiter<O>,count = 0){
      return switch(self){
        case Wait(fn)                               : Wait(fn.then(recurse.bind(_)));
        case Emit(head,tail)  if(index == count)    : Halt(Production(head));
        case Emit(head,tail)                        : recurse(tail,count++);
        case Hold(ft)                               : Hold(ft.map(recurse.bind(_,count)));
        case Halt(Terminated(cause))                : Halt(Terminated(cause));
        case Halt(Production(_))                    : Constructors.fail(Errors.no_index_found(index));
      }
    }
    return recurse(self);
  }
  static public function count<O>(self:Emiter<O>):Producer<Int>{
    return reduce(self,(next,memo) -> memo++,0);
  }
  static public function filter<O>(self:Emiter<O>,prd:O->Bool):Emiter<O>{
    return Sources.filter(self,prd);
  }
  static public function until<O>(self:Emiter<O>,prd:O->Bool):Emiter<O>{
    function recurse(self,cont){
      return switch(cont){
        case false : Halt(Production(Noise));
        case true   :
          switch(self){
            case Wait(fn)         : Wait(fn.then(recurse.bind(_,cont)));
            case Hold(ft)         : Hold(ft.map(recurse.bind(_,cont)));
            case Halt(v)          : Halt(v);
            case Emit(head,tail)  : Emit(head,recurse(tail,!prd(head)));
          } 
      }
    }
    return recurse(self,true);
  }
  static public function take<O>(self:Emiter<O>,max:Int){
    function f(n){
      return recurse.bind(_,n);
    }
    function recurse(self,n){
      return n >= max ? Halt(Production(Noise))
        : switch(self){
          case Wait(fn)         : Wait(fn.then(f(n)));
          case Hold(ft)         : Hold(ft.map(f(n)));
          case Halt(out)        : Halt(out);
          case Emit(head,tail)  : Emit(head,f(n++)(tail));
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
    function f(self:Emiter<O>) return snoc(self,o);

    return switch(self.state){
      case Halt(Production(Noise))  : self.cons(o);
      case Halt(Terminated(cause))  : self;
      case Emit(emit)               : Spx.emit(emit.mod(f)); 
      case Wait(fn)                 : Spx.wait(fn.mod(f));
      case Hold(ft)                 : Spx.hold(ft.mod(f));
      case Seek(a,n)                : Spx.seek(a,n.mod(f));
      default                       : Spx.stop();
    };
  }
  static public function cons<O>(self:Emiter<O>,v:O):Emiter<O>{
    return Emit(v,self);
  }
   static public function span(last:Int,?start:Int=0){
    var val = start;
    return Wait(
      function recurse(_){
        return if(val == last){
          Halt(Production(Noise));
        }else{
          Emit(val++,Wait(recurse));
        };
      }
    );
  }
  static public function ints(){
    var val = 0;
    function go(){
      var o = val;
      val = val +1;
      return o;
    };
    return fromThunk(go);
  }
  static public function timestamp(){
    return fromThunk(haxe.Timer.stamp);
  }
  static public function one(){
    return fromThunk(()->1);
  }
}