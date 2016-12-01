package stx.simplex.core.data;

import haxe.ds.Option;
import tink.core.Noise;

import stx.Error;

typedef Process<I,O> = stx.simplex.pack.Simplex<I,O,Option<Error>>;