package stx.coroutine.core;

/**
 *  Coroutine's return value can contain either a Production of a value or a Terminated.
 */ 
 enum ReturnSum<O,E>{
  Terminated(c:stx.coroutine.core.Cause<E>);
  Production(v:O);
}
@:using(stx.coroutine.core.Return.ReturnLift)
abstract Return<T,E>(ReturnSum<T,E>) from ReturnSum<T,E> to ReturnSum<T,E>{
  @:noUsing static public function lift<T,E>(self:ReturnSum<T,E>):Return<T,E>{
    return new Return(self);
  }
  public function new(self) this = self;
  @:from static public function fromRefuse<T,E>(e:Refuse<E>):Return<T,E>{
    return Terminated(Exit(e));
  }
  @:from static public function fromCause<T,E>(c:Cause<E>):Return<T,E>{
    return Terminated(c);
  }
  @:from static public function fromT<T,E>(v:T):Return<T,E>{
    return Production(v);
  }
  @:to public function toCoroutine<I,O>():Coroutine<I,O,T,E>{
    return Halt(lift(this));
  }
  public function toOptionUpshot():Option<Upshot<T,E>>{
    return switch(this){
      case Terminated(Stop)       : None;
      case Terminated(Exit(err))  : Some(__.reject(err));
      case Production(v)          : Some(__.accept(v));
    }
  }
  public function prj():ReturnSum<T,E>{
    return this;
  }
}

class ReturnLift{
  static public function map<T,U,E>(self:Return<T,E>,fn:T->U):Return<U,E>{
    return switch self {
      case Terminated(c): Terminated(c);
      case Production(v): Production(fn(v));
    }
  }
}