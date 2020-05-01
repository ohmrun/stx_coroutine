```haxe
package stx.coroutine.core.pack;

enum CoroutineSum<I,O,R,E>{
  Emit(o:O,next:Coroutine<I,O,R,E>);
  Wait(fn:Transmission<I,O,R,E>);
  Hold(ft:Held<I,O,R,E>);
  Halt(e:Return<R,E>);
}
```

