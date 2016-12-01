package stx.simplex.pack.Simplex.parser.data;

enum Produce<I ,O>{
  Accept(i: Null<I>, o : Null<O>);
  Reject(err: Rejection);
  Expect( err: Needed);
}