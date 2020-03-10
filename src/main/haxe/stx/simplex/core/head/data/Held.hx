package stx.simplex.core.head.data;


import stx.fn.pack.Thunk;
import stx.simplex.Package.Simplex in SimplexA;

typedef Held<I,O,R> = Thunk<Future<Simplex<I,O,R>>>;