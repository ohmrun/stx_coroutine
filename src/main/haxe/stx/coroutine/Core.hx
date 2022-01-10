package stx.coroutine;

/**
  Control Structures
**/
typedef ControlSum<I>                   = stx.coroutine.core.Control.ControlSum<I>;
typedef Control<I>                      = stx.coroutine.core.Control<I>;
 
typedef CauseSum<E>                     = stx.coroutine.core.Cause.CauseSum<E>;
typedef Cause<E>                        = stx.coroutine.core.Cause<E>;
 
typedef Held<I,O,R,E>                   = stx.coroutine.core.Held<I,O,R,E>;
 
typedef TransmissionDef<I,O,R,E>        = stx.coroutine.core.Transmission.TransmissionDef<I,O,R,E>;
typedef Transmission<I,O,R,E>           = stx.coroutine.core.Transmission<I,O,R,E>;

typedef Phase<I,O,R,E>                  = stx.coroutine.core.Phase<I,O,R,E>;
 
typedef ReturnSum<R,E>                  = stx.coroutine.core.Return.ReturnSum<R,E>;
typedef Return<R,E>                     = stx.coroutine.core.Return<R,E>;

typedef Status                          = stx.coroutine.core.Status;
typedef Errors                          = stx.coroutine.core.Errors;