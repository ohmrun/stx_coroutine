package stx.simplex.core.head.data;

/**
 *  Indicates the reason a Simplex has terminated, if it has not produced a Production.
 */
enum Cause{
  Stop;
  Early(err:Error);
  //Timeout();
}