package stx.simplex.core.head.data;

import stx.Error;

/**
 *  Indicates the reason a Simplex has terminated, if it has not produced a Production.
 */
enum Cause{
  Kill;
  Early(err:Error);
}