package stx.simplex.channel;

enum Pulse<K,V>{
  Give(v:V);
  Pull(v:K);
}