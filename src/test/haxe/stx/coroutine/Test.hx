package stx.coroutine;

using stx.Nano;
using stx.Test;
using stx.Log;

using stx.Coroutine;

import stx.coroutine.test.*;
using stx.coroutine.Logging;

class Test{
  static public function main(){
    __.logger().global().configure(
          logger -> logger.with_logic(
            logic -> logic.or(
              logic.tags(['stx/coroutine'])
            )
          )
        );


    __.test().run([
        new OverridesTest(),
        new TunnelTest()
      ],
      []
    );
    // var test = new OverridesTest();
    //     test.test();
  }
}
@stx.test.async
class OverridesTest extends TestCase{
  public function test(async:Async){
    var event = null;
        event = haxe.MainLoop.add(
          () -> {
            __.log().debug('called');
            this.pass('MainLoop called');
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