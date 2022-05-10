# stx_coroutine

```haxe
package stx.coroutine.core.pack;

enum CoroutineSum<I,O,R,E>{
  Emit(o:O,next:Coroutine<I,O,R,E>);
  Wait(fn:Transmission<I,O,R,E>);
  Hold(ft:Held<I,O,R,E>);
  Halt(e:Return<R,E>);
}
```
Stepwise Streams with input and built in flow control. 

This is about half of Gabriel Gonzalez' Haskell Pipes, with a little modification to allow adaptation to
both threaded and event based languages: `Hold`.

`CoroutineSum` describes a set of states of a unidirectional pipe, namely: 

`Wait`: Waiting for some input in order to proceed.  
`Emit`: Emiting or yielding a value, plus a reference to the rest of the `Coroutine`  
`Halt`: The `Coroutine` is terminated, either naturally with no result, with a result, or with an error.  
`Hold`: Some asynchronous condition needs be fulfilled to continue  


## Why is this useful

Conventional streams are limited in that the control of the rate of the stream is not found in their representation, and has to be bolted on. `Coroutine` allows windowing a stream in such a way as to be in finer control of intermediate results: both the producer and the consumer side have a measure of control.

## In Development

Right now, the most well developed types are `Emiter` and `Effect`.

`Emiter` conforms to a standard stream in its type definition, except it needs interpreting. The canonical way of handling this is to route the emission somewhere, transforming it to an `Effect`.  
`Effect` is a `Coroutine` where all the inputs and outputs have been accounted for, and can simply be piped to a thread to run.