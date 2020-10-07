package stx.coroutine.core;
import haxe.ds.StringMap;

enum LatchState{
  Running;
  Holding;
}

abstract Latcher{

}
abstract Latch(StringMap<LatchState>){
  private function new(self) this = self;

  static private function unit(){
    return new Latch(new StringMap());
  }
  public function get(uuid:String){
    this.set(uuid,Ongoing);
    return {
      hold : function(){
        this.set(uuid,Holding);
        changed();
      },
      run : function(){
        this.set(uuid,Running);
        changed();
      },
      stop : function(){
        this.remove(uuid);
        changed();
      }
    }
  }
  private function changed(){

  }
  static public var ZERO(default,never):Latch = unit();
}