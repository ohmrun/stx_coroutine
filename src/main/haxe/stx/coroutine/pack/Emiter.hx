package stx.coroutine.pack;

/**
 * `Stream` like `Coroutine`
 */
typedef EmiterDef<O,E> = SourceDef<O,Nada,E>;

@:using(stx.coroutine.pack.Emiter.EmiterLift)
@:forward abstract Emiter<O,E>(EmiterDef<O,E>) from EmiterDef<O,E> to EmiterDef<O,E>{
  static public var _(default,never) = EmiterLift;  
  public function new(self:EmiterDef<O,E>) this = self;
  @:noUsing static public function lift<O,E>(self:EmiterDef<O,E>) return new Emiter(self);

  @:noUsing static public function pure<T,E>(self:T):Emiter<T,E>{
    return __.emit(self,__.prod(Nada));
  }
  @:noUsing static public function unit<T,E>():Emiter<T,E>{
    return lift(__.wait(
      Transmission.fromFun1R( (_:Nada) -> __.stop()
    )));
  }
  @:noUsing static public function fromOption<O,E>(opt:Option<O>):Emiter<O,E>{
    return lift(switch (opt){
        case None     : __.stop();
        case Some(v)  : __.stop().cons(v); 
      }
    );
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
  @:noUsing static public function fromSignal<T>(self:stx.Signal<T>){
    return fromTinkSignal(self.prj());
  }
  @:noUsing static public function fromTinkSignal<T>(self:tink.core.Signal<T>){
    var buffer  = [];
    var wake    = ()->{}
    self.handle(
      (x) -> {
        buffer.push(x);
        wake();
      }
    );

    return __.hold(Held.Guard(
      new Future(
        function rec(cb){
          final f = __.emit(buffer.shift(),__.hold(Held.Guard(new Future(rec))));
          if (buffer.length == 0){
            wake = () -> {
              wake = () -> {};
              cb(f);//TODO how does this perform?  
            }
          }else{
            cb(f);
          }
          return () -> {};
        }
      )
    ));
  } 
  @:from static public function fromCoroutine<I,O,R,E>(self:Coroutine<Nada,O,Nada,E>):Emiter<O,E>{
    return lift(self);
  }
  @:to public function toCoroutine():Coroutine<Nada,O,Nada,E>{
    return this;
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
  // @:to public function toTunnel():Tunnel<Nada,O>{
  //   return this;
  // }
}
class EmiterLift{
  @:noUsing static private function lift<O,E>(self:EmiterDef<O,E>) return Emiter.lift(self);
  static public function reduce<T,U,E>(source:Emiter<T,E>,fn:T->U->U,memo:U):Derive<U,E>{
    function f(source:Emiter<T,E>,memo) { return reduce(source,fn,memo); }
    function c(memo){ return __.into(f.bind(_,memo)); } 
    return Derive.lift(switch(source){
      case Emit(head,rest)                      : 
        rest.mod(
          (spx) -> f(spx,fn(head,memo))
        );
      case Halt(Production(Nada))              : __.prod(memo);
      case Halt(Terminated(cause))              : __.term(cause);
      case Halt(_)                              : throw "Pattern match regression 062020";
      case Wait(arw)                            : __.wait(arw.mod(c(memo)));
      case Hold(ft)                             : __.hold(ft.mod(c(memo)));
    });
  }
  static public function toArray<O,E>(emt:Emiter<O,E>):Derive<Array<O>,E>{
    return reduce(emt,
      (next:O,memo:Array<O>) -> memo.concat([next])
   ,[]);
  }
  static public function append<O,E>(prc0:Emiter<O,E>,prc1:Thunk<Emiter<O,E>>):Emiter<O,E>{
    var f = __.into(append.bind(_,prc1));
    return switch (prc0){
      case Emit(head,rest)              : __.emit(head,rest.mod(f));
      case Wait(arw)                    : __.wait(arw.mod(f));
      case Halt(Production(Nada))      : prc1();
      case Halt(Terminated(cause))      : __.term(cause);
      case Halt(_)                      : throw "Pattern match regression 30/06/2020";
      case Hold(ft)                     : __.hold(ft.mod(f));
    }
  }
  static public function flat_map<O,O2,E>(prc:Emiter<O,E>,fn:O->Emiter<O2,E>):Emiter<O2,E>{
    var f = flat_map.bind(_,fn);
    return switch (prc){
      case Emit(head,rest)        : append(fn(head),f.bind(rest));
      case Wait(arw)              : __.wait(arw.mod(__.into(f)));
      case Halt(e)                : __.halt(e);
      case Hold(ft)               : __.hold(ft.mod(__.into(f)));
    }
  }
  static public function search<O,E>(self:Emiter<O,E>,prd:O->Bool):Derive<Option<O>,E>{
    function f(self){ return search(self,prd); }
    return switch(self){
      case Emit(head,rest)     if(prd(head))  : __.prod(Some(head));
      case Emit(head,rest)                    : rest.mod(__.into(search.bind(_,prd)));
      case Wait(fn)                           : __.wait(fn.mod(__.into(f)));
      case Hold(ft)                           : __.hold(ft.mod(__.into(f)));
      case Halt(Production(v))                : __.prod(None);
      case Halt(Terminated(cause))            : __.term(cause);
    }
  }
  static public function first<O,E>(self:Emiter<O,E>):Derive<Option<O>,E>{
    return search(self,(v) -> true);
  }
  static public function last<O,E>(self:Emiter<O,E>):Derive<Option<O>,E>{
    function recurse(self:Emiter<O,E>,lst:Option<O>):Derive<Option<O>,E>{
      var f = __.into(recurse.bind(_,lst));
      return switch([self,lst]){
        case [Emit(head,rest),_]                : rest.mod(__.into(recurse.bind(_,Some(head))));
        case [Wait(fn),_]                       : __.wait(fn.mod(f));
        case [Hold(ft),_]                       : __.hold(ft.mod(f));
        case [Halt(Production(Nada)),v]        : __.prod(v);
        case [Halt(Terminated(cause)),_]        : __.term(cause);
        case [Halt(_),v]                        : __.prod(v);
      }
    }
    return recurse(self,None);
  }
  static public function at<O,E>(self:Emiter<O,E>,index:Int):Derive<Option<O>,E>{
    function recurse(self:Emiter<O,E>,count = 0){
      var f = (int) -> __.into(recurse.bind(_,int));
      var c = f(count);
      return switch(self){
        case Wait(fn)                               : __.wait(fn.mod(c));
        case Emit(head,tail)  if(index == count)    : __.prod(Some(head));
        case Emit(head,tail)                        : tail.mod(f(count + 1));
        case Hold(ft)                               : __.hold(ft.mod(c));
        case Halt(Terminated(cause))                : __.term(cause);
        case Halt(Production(_))                    : __.prod(None);
      }
    }
    return recurse(self);
  }
  static public function count<O,E>(self:Emiter<O,E>):Derive<Int,E>{
    return reduce(self,(next,memo) -> memo++,0);
  }
  static public function until<O,E>(self:Emiter<O,E>,prd:O->Bool):Emiter<O,E>{
    function recurse(self,cont){
      var f = __.into(recurse.bind(_,cont));
      return switch(cont){
        case false : __.prod(Nada);
        case true   :
          switch(self){
            case Wait(fn)         : __.wait(fn.mod(f));
            case Hold(ft)         : __.hold(ft.mod(f));
            case Halt(v)          : __.halt(v);
            case Emit(head,tail)  : tail.mod(
              __.into((self) -> recurse(self,!prd(head)))
            );
          } 
      }
    }
    return recurse(self,true);
  }
  static public function take<O,E>(self:Emiter<O,E>,max:Int){
    function recurse(self,n){
      var f = (n) -> __.into(recurse.bind(_,n));
      return n >= max ? Halt(Production(Nada))
        : switch(self){
          case Wait(fn)         : __.wait(fn.mod(f(n)));
          case Hold(ft)         : __.hold(ft.mod(f(n)));
          case Halt(out)        : __.halt(out);
          case Emit(head,tail)  : __.emit(head,f(n++)(tail));
        }
    }
    return recurse(self,1);
  }
  static public function cons<O,E>(self:Emiter<O,E>,v:O):Emiter<O,E>{
    return __.emit(v,self);
  }
  /**
   *  Adds another value to the end of this Emiter *if* it terminates.
   *  If the original Emiter does not terminate, the value will never be available.
   *  @param o - 
   *  @return Emiter<O,E>
   */
  static public function snoc<O,E>(self:Emiter<O,E>,o:O):Emiter<O,E>{
    var f = __.into(snoc.bind(_,o));
    return switch(self){
      case Halt(Production(Nada))  : self.cons(o);
      case Halt(Terminated(cause))  : self;
      case Emit(head,rest)          : __.emit(head,rest.mod(f)); 
      case Wait(fn)                 : __.wait(fn.mod(f));
      case Hold(ft)                 : __.hold(ft.mod(f));
      default                       : __.stop();
    };
  }
  static public function span(last:Int,?start:Int=0){
    var val = start;
    return Wait(
      function recurse(_){
        return if(val == last){
          __.prod(Nada);
        }else{
          __.emit(val++,__.wait(recurse));
        };
      }
    );
  }
  static public function filter<O,E>(self:Emiter<O,E>,prd:O->Bool):Emiter<O,E>{
    return Emiter.lift(Source._.filter(Source.lift(self),prd));
  }
  static public function secure<O,E>(self:Emiter<O,E>,next:Secure<O,E>):Effect<E>{
    function recurse(self:Coroutine<Nada,O,Nada,E>,next:Coroutine<O,Nada,Nada,E>):Coroutine<Nada,Nada,Nada,E>{
      var fl = __.into(recurse.bind(_,next));
      return Effect.lift(switch([self,next]){
        case [Emit(head,tail),Wait(fn)] : recurse(tail,fn(Push(head)));
        case [Halt(out),_]              : __.halt(out);
        case [_,Halt(out)]              : __.halt(out);
        case [Wait(fn),_]               : __.wait(fn.mod(fl));
        case [Hold(ft),_]               : __.hold(ft.mod(fl));
        case [_,Emit(head,tail)]        : recurse(self,tail);
        case [_,Hold(ft)]               : __.hold(ft.mod(recurse.bind(self)));
      });
    }
    return recurse(self,next);
  }
  static public function sample<O,R,E>(self:Emiter<O,E>,fn:O->R->Chunk<R,E>,init:R):Source<O,R,E>{
    var data = init;
    function rec(self:CoroutineSum<Nada,O,Nada,E>):Coroutine<Nada,O,R,E>{
      return switch(self){
        case Emit(o,next)   :
          final step = fn(o,data);
          switch(step){
            case Val(v) : 
              data = v;
              rec(next);
            case End(null) : 
              __.prod(data);
            case End(err)  : 
              __.quit(err);
            case Tap :
              rec(next);
          }
        case Wait(tran)     :
          __.wait(tran.mod(rec));
        case Hold(held)     :
          __.hold(held.mod(rec));
        case Halt(Terminated(Stop))     :
          __.prod(data);
        case Halt(Terminated(r))        :
          __.halt(Terminated(r));
        case Halt(Production(r))         :
          __.halt(Production(data));
      }
    }
    return rec(self);
  }
  static public function derive<O,R,E>(self:EmiterDef<O,E>,pure:O->R,plus:R->R->R,zero:R):Derive<R,E>{
    var value = zero;
    function f(self){
      return switch(self){
        case Emit(o,next) : 
          value = plus(pure(o),zero);
          __.emit(Nada,__.hold(Held.Pause(f.bind(next))));
        case Wait(tran)                   : __.wait(tran.mod(f));
        case Hold(held)                   : __.hold(held.mod(f));
        case Halt(Production(_))          : __.prod(value);
        case Halt(Terminated(cause))      : __.term(cause);
      }
    }
    return f(self);
  }
}