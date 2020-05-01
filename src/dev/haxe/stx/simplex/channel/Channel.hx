package stx.coroutine.channel;

typedef Channel<K,V> = stx.coroutine.Package.Pipe<Pulse<K,V>,V>;