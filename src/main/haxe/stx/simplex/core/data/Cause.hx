package stx.simplex.core.data;

import stx.Error;

enum Cause{
  Kill;
  Finished;
  Early(err:Error);
}