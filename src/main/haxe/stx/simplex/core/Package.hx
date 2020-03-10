package stx.simplex.core;

/**
 *  Abstract wrapper for basetype stx.simplex.core.data.Simplex, attaching various combinators.
 */
typedef Simplex<I,O,R>  = stx.simplex.core.pack.Simplex<I,O,R>; 
/**
 *  Instructs the Stream on requirements
 */
typedef Control<I>      = stx.simplex.core.pack.Control<I>;
/**
 * Indicates a state where the next value may be resolved. 
 */
typedef Held<I,O,R>     = stx.simplex.core.pack.Held<I,O,R>;
/**
 *  Function used to consume input to produce the next value.
 */
typedef Emission<I,O,R> = stx.simplex.core.pack.Emission<I,O,R>;

typedef Controls        = stx.simplex.core.body.Controls;
typedef Errors          = stx.simplex.core.body.Errors;
typedef Scheduler       = stx.simplex.core.pack.Scheduler;
typedef Schedule        = stx.simplex.core.pack.Schedule;
typedef State<I,O,R>    = stx.simplex.core.pack.State<I,O,R>;
typedef Interface<I,O,R> = stx.simplex.core.head.data.Interface<I,O,R>;
typedef Operator<T>     = stx.simplex.core.pack.Operator<T>;
typedef Op<T>           = stx.simplex.core.pack.Op<T>;