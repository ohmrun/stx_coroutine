package stx.simplex.core.head.data;

import stx.simplex.core.pack.Emiting in EmitingA;
import stx.simplex.core.pack.Simplex in SimplexA;

enum State<I,O,R>{
  Emit(e:EmitingA<I,O,R>);
  Wait(arw:stx.simplex.core.Package.Emission<I,O,R>);
  Hold(ft:stx.simplex.core.Package.Held<I,O,R>);
  Halt(e:Return<R>);
  Seek(a:Advice,to:SimplexA<I,O,R>);
}