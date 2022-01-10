package stx.coroutine.core;

enum Phase<I,O,R,E>{
  Ipt(i:Control<I>);
  Opt(o:O);
  Rtn(o:Return<R,E>);
}