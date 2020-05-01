package stx.coroutine.pack.Coroutine.parser.data;

typedef Seq<T> = {
  function next():Void;
  function peek():Null<T>;
  function done():Bool;
}