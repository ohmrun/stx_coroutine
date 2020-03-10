package stx.simplex;

import utest.Assert;

class TestEmiters implements utest.ITest{
  public function new(){}

  public function testUints(){
    Emiters.ints().until((x)-> x == 10).reduce(
      (next,memo) -> {
        return next;
      },0
    ).complete(
      (x)->Assert.equals(10,x)
    ).run();
  }
}