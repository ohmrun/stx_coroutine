package stx.simplex.core.head.data;

enum Advice{
  Give;
  Take;
  Pick;
  Poll(?t:Float);
  Hung(?c:Cause);
}