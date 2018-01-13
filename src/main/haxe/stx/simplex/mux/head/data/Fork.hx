package stx.simplex.mux.head.data;

typedef Fork<I,L,R> = Pipe<I,Either<L,R>>;