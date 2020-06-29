package stx.coroutine.core.pack;

/**
 *  Coroutine's return value can contain either a Production of a value or a Terminated.
 */ 
 enum ReturnSum<O,E>{
  Terminated(c:stx.coroutine.core.pack.Cause<E>);
  Production(v:O);
}
@:using(stx.coroutine.core.pack.Return.ReturnLift)
abstract Return<T,E>(ReturnSum<T,E>) from ReturnSum<T,E> to ReturnSum<T,E>{
  public function new(self){
    this = self;
  }
  @:from static public function fromError<T,E>(e:Err<E>):Return<T,E>{
    return fromCause(Exit(e));
  }
  @:from static public function fromCause<T,E>(c:Cause<E>):Return<T,E>{
    return Terminated(c);
  }
  @:from static public function fromT<T,E>(v:T):Return<T,E>{
    return Production(v);
  }
  @:to public function toCoroutine<I,O,E>():Coroutine<I,O,T,E>{
    return Halt(this);
  }
  public function toOptionRes():Option<Res<T,E>>{
    return switch(this){
      case Terminated(Stop)       : None;
      case Terminated(Exit(err))  : Some(__.failure(err));
      case Production(v)          : Some(__.success(v));
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