package stx.coroutine.pack.Coroutine.parser.data;

enum Produce<I ,O>{
  Accept(i: Null<I>, o : Null<O>);
  Reject(err: Rejection);
  Expect( err: Needed);
}