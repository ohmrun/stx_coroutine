package stx.simplex;

import utest.Assert;

class TestProducers implements utest.ITest{
  public function new(){}
  public function testComplete(){

    var val = 0;
    function counter(_):Producer<Int>{
      val++;
      return val == 10 ? Halt(Production(val)) : Wait(counter);
    }
    Producers.complete(Wait(counter),(x) -> null).run();

    Assert.equals(10,val);
  }
}