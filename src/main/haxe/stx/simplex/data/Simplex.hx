package stx.simplex.data;

import tink.CoreApi;
import stx.async.Arrowlet;

enum Simplex<I,O,R>{
  Emit(head:O,tail:stx.Simplex<I,O,R>);
  Wait(arw:I->stx.Simplex<I,O,R>);
  Held(ft:Future<stx.Simplex<I,O,R>>);
  Halt(e:R);
}
