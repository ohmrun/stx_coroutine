package stx.simplex.pack;

typedef EmiterDef<O,E> = SourceDef<O,Noise,E>;

@:using(stx.simplex.pack.Emiter.EmiterLift)
@:forward abstract Emiter<O,E>(EmiterDef<O,E>) from EmiterDef<O,E> to EmiterDef<O,E>{
  public function new(self:EmiterDef<O,E>) this = self;
  @:noUsing static public function lift<O,E>(self:EmiterDef<O,E>) return new Emiter(self);

  @:noUsing static public function unit<T,E>():Emiter<T,E>{
    return lift(__.wait(
      Transmission.fromFun1R( (_:Noise) -> __.stop()
    )));
  }
  @:noUsing static public function fromOption<O,E>(opt:Option<O>):Emiter<O,E>{
    return lift(Held.lazy(
      () -> switch (opt){
        case None     : __.stop();
        case Some(v)  : __.stop().cons(v); 
      }
    ));
  }
  
  @:noUsing static public function fromThunk<O,E>(thk:Thunk<O>):Emiter<O,E>{
    return lift(Held.lazy(
      function recurse(){
        return Held.lazy(recurse).cons(thk());
      }
    ));
  }
  /**
   *  Produces a one shot Emiter from any iterable.
   *  Closure created lazily.
   *  @param iter - 
   *  @return Emiter<T>
   */
  @:noUsing static public function fromIterator<T,E>(iter:Iterator<T>):Emiter<T,E>{
    return lift(Held.lazy(
      function recurse(){
        return switch(iter.hasNext()){
          case true   : Held.lazy(recurse).cons(iter.next());
          case false  : __.stop(); 
        }
      }
    ));
  }
  static public function ints(){
    var val = 0;
    function go(){
      var o = val;
      val = val +1;
      return o;
    };
    return Emiter.fromThunk(go);
  }
  static public function timestamp(){
    return Emiter.fromThunk(haxe.Timer.stamp);
  }
  static public function one(){
    return Emiter.fromThunk(()->1);
  }
  // @:to public function toPipe():Pipe<Noise,O>{
  //   return this;
  // }
}
class EmiterLift{
  @:noUsing static public function lift<O,E>(self:EmiterDef<O,E>) return Emiter.lift(self);
  static public function reduce<T,U,E>(source:Emiter<T,E>,fn:T->U->U,memo:U):Producer<U,E>{
    function f(source:Emiter<T,E>,memo) { return reduce(source,fn,memo); }
    function c(memo){ return f.bind(_,memo); } 
    return Producer.lift(switch(source){
      case Emit(head,rest)                      : f(head,rest.mod(fn.bind(_,memo)));
      case Halt(Production(Noise))              : __.done(memo);
      case Halt(Terminated(cause))              : __.term(cause);
      case Wait(arw)                            : __.wait(arw.mod(c(memo)));
      case Hold(ft)                             : __.held(ft.mod(c(memo)));
    });
  }
  static public function toArray<O,E>(emt:Emiter<O,E>):Producer<Array<O>,E>{
    return reduce(emt,
      (next:O,memo:Array<O>) -> memo.concat([next])
   ,[]);
  }
  static public function flat_map<O,O2,E>(prc:Emiter<O,E>,fn:O->Emiter<O2,E>):Emiter<O2,E>{
    function f(prc) return flat_map(prc,fn);
    return switch (prc){
      case Emit(head,rest)        : append(fn(head),f.bind(rest));
      case Wait(arw)              : __.wait(arw.mod(f));
      case Halt(e)                : __.done(e);
      case Hold(ft)               : __.held(ft.mod(f));
    }
  }
  static public function append<O,E>(prc0:Emiter<O,E>,prc1:Thunk<Emiter<O,E>>):Emiter<O,E>{
    function f(prc0) return append(prc0,prc1);
    return switch (prc0){
      case Emit(head,rest)                   : __.emit(emit.mod(f));
      case Wait(arw)                    : __.wait(arw.mod(f));
      case Halt(Production(Noise))      : prc1();
      case Halt(Terminated(cause))      : __.term(cause);
      case Hold(ft)                     : __.held(ft.mod(f));
    }
  }
  static public function search<O,E>(self:Emiter<O,E>,prd:O->Bool):Producer<O,E>{
    function f(self){ return search(self,prd); }
    return switch(self){
      case Emit(head,rest)     if(prd(head))  : __.done(head);
      case Emit(head,rest)                    : search(rest,prd);
      case Wait(fn)                           : __.wait(fn.then(f));
      case Hold(ft)                           : ft.map(f);
      case Halt(Production(v))                : Errors.no_value_error();
      case Halt(Terminated(cause))            : cause;
    }
  }
  static public function first<O,E>(self:Emiter<O,E>):Producer<O,E>{
    return search(self,(v) -> true);
  }
  static public function last<O,E>(self:Emiter<O,E>):Producer<O,E>{
    function recurse(self:Emiter<O,E>,lst:Option<O,E>):Producer<O,E>{
      function f(self){
        return recurse(self,lst);
      }
      return switch([self,lst]){
        case [Emit(emit),_]                     : recurse(rest,Some(head));
        case [Wait(fn),_]                       : Wait(fn.then(f));
        case [Hold(ft),_]                       : ft.map(f);
        case [Halt(Production(Noise)),None]     : Errors.no_value_error();
        case [Halt(Production(Noise)),Some(v)]  : __.done(v);
        case [Halt(Terminated(cause)),_]        : cause;
      }
    }
    return recurse(self,None);
  }
  static public function at<O,E>(self:Emiter<O,E>,index:Int):Producer<O,E>{
    function recurse(self:Emiter<O,E>,count = 0){
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
  static public function count<O,E>(self:Emiter<O,E>):Producer<Int,E>{
    return reduce(self,(next,memo) -> memo++,0);
  }
  static public function filter<O,E>(self:Emiter<O,E>,prd:O->Bool):Emiter<O,E>{
    return Sources.filter(self,prd);
  }
  static public function until<O,E>(self:Emiter<O,E>,prd:O->Bool):Emiter<O,E>{
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
  static public function take<O,E>(self:Emiter<O,E>,max:Int){
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
  static public function sink<O,E>(self:Emiter<O,E>,next:Sink<O>):Effect<E>{
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
  /**
   *  Adds another value to the end of this Emiter *if* it terminates.
   *  If the original Emiter does not terminate, the value will never be available.
   *  @param o - 
   *  @return Emiter<O,E>
   */
  static public function snoc<O,E>(self:Emiter<O,E>,o:O):Emiter<O,E>{
    function f(self:Emiter<O,E>) return snoc(self,o);

    return switch(self){
      case Halt(Production(Noise))  : self.cons(o);
      case Halt(Terminated(cause))  : self;
      case Emit(head,rest)          : __.emit(rest.mod(f)); 
      case Wait(fn)                 : __.wait(fn.mod(f));
      case Hold(ft)                 : __.hold(ft.mod(f));
      default                       : __.stop();
    };
  }
  static public function cons<O,E>(self:Emiter<O,E>,v:O):Emiter<O,E>{
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
}