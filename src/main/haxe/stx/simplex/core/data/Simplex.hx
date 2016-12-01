package stx.simplex.core.data;

import tink.CoreApi;
import stx.async.Arrowlet;

import stx.simplex.pack.Cause;
import stx.simplex.pack.Return;
import stx.simplex.pack.Control;
import stx.simplex.pack.Simplex in SimplexC;

enum Simplex<I,O,R>{
  Emit(head:O,tail:Simplex<I,O,R>);
  Wait(arw:Control<I>->Simplex<I,O,R>);
  Held(ft:Future<Simplex<I,O,R>>);
  Halt(e:Return<R>);
}
