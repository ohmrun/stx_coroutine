package stx.simplex.core.data;

import tink.core.Either;

import stx.simplex.pack.Simplex;

typedef SamplerT<I,O,R> = Simplex<I,Either<I,O>,R>;