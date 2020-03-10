package stx.simplex;


// typedef Effect              = stx.simplex.pack.Effect;                  //000
// typedef Producer<R>         = stx.simplex.pack.Producer<R>;             //001
// typedef Emiter<O>           = stx.simplex.pack.Emiter<O>;               //010
// typedef Source<O,R>         = stx.simplex.pack.Source<O,R>;             //011
// typedef Sink<I>             = stx.simplex.pack.Sink<I>;                 //100
// typedef Fold<I,R>           = stx.simplex.pack.Fold<I,R>;               //101
//typedef Pipe<I,O>           = stx.simplex.pack.Pipe<I,O>;               //110
typedef Simplex<I,O,R>      = stx.simplex.core.Package.Simplex<I,O,R>;  //111

//typedef Tween               = stx.simplex.pack.Tween;
//typedef Producers           = stx.simplex.body.Producers;
//typedef Emiters             = stx.simplex.body.Emiters;
//typedef Folds               = stx.simplex.body.Folds;
//typedef Reactor<I,O,R>      = stx.simplex.pack.Reactor<I,O,R>;
//typedef Arrow<P,I,O,R>      = stx.simplex.pack.Arrow<P,I,O,R>;
#if sys
  //  typedef Sleep            = stx.simplex.pack.Sleep;
#end