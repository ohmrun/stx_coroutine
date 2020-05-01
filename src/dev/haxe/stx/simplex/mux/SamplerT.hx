package stx.coroutine.core.data;

import tink.core.Either;

import stx.coroutine.pack.Coroutine;

typedef SamplerT<I,O,R> = Coroutine<I,Either<I,O>,R>;