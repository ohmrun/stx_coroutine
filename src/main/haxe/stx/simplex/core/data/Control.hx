package stx.simplex.core.data;

enum Control<T>{
  Continue(v:T);
  Discontinue(v:stx.simplex.pack.Cause);
}