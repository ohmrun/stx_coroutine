package stx.simplex.core.pack;

enum Phase<I,O,R,E>{
  Ipt(i:Control<I,E>);
  Opt(o:O);
  Rtn(o:Return<R,E>);
}