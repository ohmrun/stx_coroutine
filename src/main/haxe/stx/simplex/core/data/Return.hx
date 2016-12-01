package stx.simplex.core.data;

enum Return<T>{
  Terminated(c:stx.simplex.pack.Cause);
  Production(v:T);
}