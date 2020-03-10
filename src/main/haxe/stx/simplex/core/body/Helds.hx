package stx.simplex.core.body;

class Helds{
  static public function poll<I,O,R>(self:Held<I,O,R>,?time:Float):Simplex<I,O,R>{
    return Spx.seek(Poll(time),self);
  }
  static public function hung<I,O,R>(self:Held<I,O,R>,?e):Simplex<I,O,R>{
    var held = Spx.hold(self);
    return Spx.seek(Hung(e),held);
  }
}