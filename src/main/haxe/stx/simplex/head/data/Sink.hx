package stx.simplex.head.data;


/**
 *  Receives Values and may only return an Error, or a termination notification.
 */
typedef Sink<I> = Interface<I,Noise,Noise>;