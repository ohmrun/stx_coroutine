package stx.simplex.core.head.data;


/**
 *  Used to notify the Wait state of an intention to Terminate.
 */
enum Control<T>{
  Push(v:T);
  Pull;
  Exit(v:stx.simplex.core.pack.Cause);
  Okay;
}