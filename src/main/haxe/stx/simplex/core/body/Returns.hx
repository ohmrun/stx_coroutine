package stx.simplex.core.body;

class Returns{
  static public function map<T,U>(ret:Return<T>,fn:T->U):Return<U>{
    return switch ret{
      case Terminated(c): Terminated(c);
      case Production(v): Production(fn(v));
    }
  }
}