package stx.simplex.core.head.data;

/**
 *  Simplex's return value can contain either a Production of a value or a Terminated.
 */
enum Return<O>{
  Terminated(c:stx.simplex.core.pack.Cause);
  Production(v:O);
}