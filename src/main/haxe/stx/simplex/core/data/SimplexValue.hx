package stx.simplex.core.data;

enum SimplexValue<I,O,R>{
  SimplexInput(i:Control<I>);
  SimplexOutput(o:O);
  SimplexReturn(o:Return<R>);
}