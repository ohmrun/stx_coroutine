package stx.simplex.core.pack;

/**
 *  Simplex's return value can contain either a Production of a value or a Terminated.
 */
 enum ReturnSum<O,E>{
  Terminated(c:stx.simplex.core.pack.Cause<E>);
  Production(v:O);
}
@:using(stx.simplex.core.pack.Return.ReturnLift)
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
  @:to public function toSimplex<I,O,E>():Simplex<I,O,T,E>{
    return Halt(this);
  }
}

class ReturnLift{
  static public function map<T,U,E>(self:Return<T,E>,fn:T->U):Return<U,E>{
    return switch self{
      case Terminated(c): Terminated(c);
      case Production(v): Production(fn(v));
    }
  }
}