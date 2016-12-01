package stx.simplex.pack.Simplex.parser.data;

typedef Seq<T> = {
  function next():Void;
  function peek():Null<T>;
  function done():Bool;
}