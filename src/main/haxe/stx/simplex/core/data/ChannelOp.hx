package stx.simplex.core.data;

enum ChannelOp<T>{
  Push(v:T);
  Pull;
}