using stx.Nano;
using stx.Log;

class Main{
  static function main(){
    final logger = __.log().global;
          logger.includes.push("stx/coroutine");
          logger.includes.push("stx/test");
          logger.includes.push('haxe/overrides');
    stx.coroutine.Test.main();
  }
}