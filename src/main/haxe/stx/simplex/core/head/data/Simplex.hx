package stx.simplex.core.head.data;

import stx.simplex.core.head.Data;

enum Simplex<I,O,R>{
  Emit(head:O,tail:stx.simplex.core.pack.Simplex<I,O,R>);
  Wait(arw:stx.simplex.core.Package.Emission<I,O,R>);
  Hold(ft:stx.simplex.core.Package.Held<I,O,R>);
  Halt(e:Return<R>);
}
