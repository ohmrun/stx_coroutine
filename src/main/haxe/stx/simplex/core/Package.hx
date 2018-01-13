package stx.simplex.core;

/**
 *  Abstract wrapper for basetype stx.simplex.core.data.Simplex, attaching various combinators.
 */
typedef Simplex<I,O,R>  = stx.simplex.core.pack.Simplex<I,O,R>; 
/**
 *  Input to Emission, instructing the Function on whether or not it wishes to continue the Simplex.
 */
typedef Control<I>      = stx.simplex.core.pack.Control<I>;

/**
 * Indicates a state where the next value has not yet resolved. 
 */
typedef Held<I,O,R>     = stx.simplex.core.pack.Held<I,O,R>;

/**
 *  Function used to consume input to produce the next value.
 */
typedef Emission<I,O,R> = stx.simplex.core.pack.Emission<I,O,R>;