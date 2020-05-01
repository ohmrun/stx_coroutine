package stx.coroutine.core.data;

typedef Interleave<L,R,O> = Pipe<Either<L,R>,O>;