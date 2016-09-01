import stx.simplex.data.Simplex;
using stx.Simplex;



import stx.simplex.data.Producer;

using tink.CoreApi;

using tink.CoreApi;

using Lambda;
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
      new TestSimplex()
    ];
    arr.iter(
      function(c){
        r.addCase(c);
      }
    );
    r.run();
  }
}
class TestSimplex{
  public function new(){}
  public function testConstruct(){
    var a : Simplex<Int,String,Error> = function(i:Int){
      return '$i numbers of fucks am I currently giving';
    }
    var count = 0;

    var b : Producer<Int,Error> = function(){
      var out = count+1;
      return if(count < 10){
        count = out;
      }else{
        throw "Too many fucks given";
      }
    }

    var d = b.pipe(a).press();

    function driver(simplex:Simplex<Noise,String,Error>){
      //trace('driver: $simplex');
      switch(simplex){
        case Wait(arw):
        driver(arw(Noise));
        case Emit(o,nxt): trace('EMIT: $o'); driver(nxt);
        case Halt(e):
          trace(e);
          throw(e);
        case Held(ft):
          //trace("driver held");
          ft.handle(driver);
        default: trace("?");
      }
      //trace('HERE: $simplex');
    }
    driver(d);
    trace("DONE");
  }
}
