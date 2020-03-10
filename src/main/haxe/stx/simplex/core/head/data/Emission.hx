package stx.simplex.core.head.data;

import stx.fn.pack.Unary;
import stx.simplex.core.pack.Operator in OperatorA;
import stx.simplex.core.pack.Simplex in SimplexA;

typedef Emission<I,O,R> = Unary<OperatorA<I>,SimplexA<I,O,R>>;