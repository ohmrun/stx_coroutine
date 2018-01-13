
using stx.Tuple;
import stx.Chunk;

using stx.simplex.Package;

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
      //new TestSimplex(),
      //new stx.simplex.ParserTest(),
      new TestSource(),
    ];
    arr.iter(
      function(c){
        r.addCase(c);
      }
    );
    r.run();
  }
}
class TestSource{
  public function new(){}
  public function test(){
    var a                 = [1,2,3];
    var b : Emiter<Int>   = a;
    pass();
  }
  public function testA(){
    /*
      var acc0 = new Accumulator();
      var acc1 = new Accumulator();
    */
    var a   = [1,2,3];
    var b   = [4,5,6];
    var o   = [];
    var t0 = Future.trigger();
    var t1 = Future.trigger();

    var simplex0 = a.toEmiter();
    var simplex1 = b.toEmiter();
    var simplex2 = simplex0.merge(simplex1);
    var stream   = simplex2.toGenerate(); 
        stream.forEach(
          function(x){
            o.push(x);
            return true;
          }
        );
    same(a.concat(b),o);
  }
  function printer(?pos:haxe.PosInfos){
    return function(d:Dynamic ){
      haxe.Log.trace(d,pos);
    }
  }
  public function testB(){
    var a = Emiter.unit();
    var o = [];
    var b = 
      a.snoc(1)
       .snoc(2)
       .snoc(3);

      b.toGenerate().forEach(
        function(x){
          o.push(x);
          return true;
        }
      );

    same([1,2,3],o);

    b.snoc(4);
  }
  /*public function testLifo(){
    var a = FIFO.unit();
    var b = a.push(1).push(2).push(3);
    var o = [];  
    var d = b.toSource().toGenerate();
        d.forEach(
          function(x){
            o.push(x);
            return true;
          }
        );
    
    same([1,2,3],o);
  }*/
  public function testSubstream(){
    function go(x:Dynamic){
      //trace('go $x');
      return true;
    }
    var a : Emiter<{ a : Array<Int> }> = [
      {
        a : [1,2,3]
      },
      {
        a : [4,5,6]
      }
    ];
    var b = a.flatMap(
      function(x){
        var src               = Iterables.toEmiter(x.a);
        var out               = src.map(tuple2.bind(x));
        return out;
      }
    );
    b.pipeTo(printer());
  }
}
class TestSimplex{
  public function new(){}
  /*
  public function testConstruct(){
    var a = function(i:Int){
      return '$i numbers of fucks am I currently giving';
    }.toSource();
    var count = 0;

    var b : Producer<Int> = function(){
      var out = count+1;
      return if(count < 10){
        count = out;
      }else{
        throw "Too many fucks given";
      }
    }

    var d = b.pipe(a).press();

    function driver(simplex:Simplex<Noise,String,Noise>){
      //trace('driver: $simplex');
      switch(simplex){
        case Wait(arw):
        driver(arw(Noise));
        case Emit(o,nxt): trace('EMIT: $o'); driver(nxt);
        case Halt(e):
          trace(e);
          pass();
        case Hold(ft):
          //trace("driver Hold");
          ft.handle(driver);
        default: trace("?");
      }
      //trace('HERE: $simplex');
    }
    //driver(d);
  }
  */
}