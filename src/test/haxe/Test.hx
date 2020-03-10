using Lambda;

import stx.simplex.core.body.Simplexs;

import utest.Runner;
import utest.Assert.*;

class Test{
  static function main(){
    new Test();
  }
  public function new(){
    var r = new Runner();
    utest.ui.Report.create(r);
    var arr : Array<Dynamic> = [
      //new stx.simplex.TestProducers(),
      //new stx.simplex.TestEmiters(),
      //new TestSimplex(),
      //new stx.simplex.ParserTest(),
      //new TestSource(),
      new stx.simplex.TestSimplex()
    ];
    arr.iter(
      function(c){
        r.addCase(c);
      }
    );
    r.run();
  }
}