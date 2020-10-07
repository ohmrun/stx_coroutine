package stx.coroutine;


import utest.Assert in Rig;
import utest.Async;
import utest.Test;

using stx.Coroutine;

class Test{
  static public function main(){
    utest.UTest.run([
      new LatchTest(),
    ]);
  }
}
class LatchTest extends utest.Test{
  public function test(){
      
  }
}