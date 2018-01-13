package stx.simplex.core.head.data;

enum Phase<I,O,R>{
  Ipt(i:Control<I>);
  Opt(o:O);
  Rtn(o:Return<R>);
}