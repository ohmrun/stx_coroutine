package stx.coroutine;

using stx.Nano;
using stx.Test;

using stx.Coroutine;

using stx.coroutine.Logging;

class Test{
  static public function main(){
    Logger.ZERO.includes.push("stx/coroutine");

    __.log().info('test');
    __.test().run([
        new OverridesTest(),
      ],
      []
    );
    // var test = new OverridesTest();
    //     test.test();
  }
}
class OverridesTest extends TestCase{
  public function test(async:Async){
    var event = null;
        event = haxe.MainLoop.add(
          () -> {
            __.log().debug('called');
            event.stop();
            async.done();
          }
        );
  }
}
class LatchTest extends TestCase{
  public function test(){
      
  }
}
class EmiterTest extends TestCase{

}