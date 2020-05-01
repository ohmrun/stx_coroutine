package stx.coroutine.mux.head.data;

typedef Partial<LI,RI,LO,RO> = Pipe<Either<LI,RI>,Either<LO,RO>>;