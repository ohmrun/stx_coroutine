package stx.coroutine.channel;

enum Pulse<K,V>{
  Give(v:V);
  Pull(v:K);
}