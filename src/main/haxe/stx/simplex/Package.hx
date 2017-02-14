package stx.simplex;

import stx.simplex.core.Data;

//typedef Catamorphism<I,R> = stx.simplex.pack.Catamorphism<I,R>;
typedef Cause             = stx.simplex.pack.Cause;

//typedef Channel<T>        = stx.simplex.pack.Channel<T>;
typedef FIFO<T>           = stx.simplex.pack.channel.FIFO<T>;
//typedef ChannelOp<T>      = stx.simplex.pack.ChannelOp<T>;
//typedef Completer<R>      = stx.simplex.pack.Completer<R>;
typedef Concludes           = stx.simplex.pack.Concludes;
typedef Causes           = stx.simplex.pack.Causes;
typedef Consumer<T,R>     = stx.simplex.pack.Consumer<T,R>;

typedef Control<T>        = stx.simplex.pack.Control<T>;
typedef Controls          = stx.simplex.pack.Controls;
typedef Effects           = stx.simplex.pack.Effects;
typedef Mux<L,R>          = stx.simplex.pack.Mux<L,R>;
typedef Muxs              = stx.simplex.pack.Muxs;
typedef Pipe<I,O>         = stx.simplex.pack.Pipe<I,O>;
typedef Process<I,O>      = stx.simplex.pack.Process<I,O>;
typedef Processes         = stx.simplex.pack.Processes;
typedef Producer<O,R>     = stx.simplex.pack.Producer<O,R>;
typedef Return<R>         = stx.simplex.pack.Return<R>;
typedef Sampler<I,O,R>    = stx.simplex.pack.Sampler<I,O,R>;
typedef Shipment<T>       = stx.simplex.pack.source.Shipment<T>;
typedef Simplex<I,O,R>    = stx.simplex.pack.Simplex<I,O,R>;
typedef Simplexs          = stx.simplex.pack.Simplexs;
//typedef Sink<I>           = stx.simplex.pack.Sink<I>;
typedef Source<O>         = stx.simplex.pack.Source<O>;
typedef Sources           = stx.simplex.pack.Sources; 