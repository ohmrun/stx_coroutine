
using stx.Tuple;
import stx.Chunk;
import stx.simplex.core.Data;
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
    var b : Source<Int>   = a;
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

    var simplex0 : Source<Int> = a;
    var simplex1 : Source<Int> = b;
    var simplex2 = simplex0.merge(simplex1);
    var stream   = simplex2.toStream(); 
        stream.forEach(
          function(x){
            o.push(x);
            return true;
          }
        );
    same(a.concat(b),o);
  }
  function printer(?pos:haxe.PosInfos){
    return function(d:Dynamic){
      haxe.Log.trace(d,pos);
    }
  }
  public function testB(){
    var a = Source.unit();
    var o = [];
    var b = 
      a.emit(1)
       .emit(2)
       .emit(3);

      b.toStream().forEach(
        function(x){
          o.push(x);
          return true;
        }
      );

    same([1,2,3],o);

    b.emit(4);
  }
  public function testLifo(){
    var a = FIFO.unit();
    var b = a.push(1).push(2).push(3);
    var o = [];  
    var d = b.toSource().toStream();
        d.forEach(
          function(x){
            o.push(x);
            return true;
          }
        );
    
    same([1,2,3],o);
  }
  public function testSubstream(){
    function go(x:Dynamic){
      //trace('go $x');
      return true;
    }
    var a : Source<{ a : Array<Int> }> = [
      {
        a : [1,2,3]
      },
      {
        a : [4,5,6]
      }
    ];
    var b = a.flatMap(
      function(x){
        var src               = Source.fromIterable(x.a);
        var out               = src.map(tuple2.bind(x));
        return out;
      }
    );
    b.pipeTo(printer());
  }
}
class TestSimplex{
  public function new(){}
  public function testConstruct(){
    var a : Simplex<Int,String,Noise> = function(i:Int){
      return '$i numbers of fucks am I currently giving';
    }
    var count = 0;

    var b : Producer<Int,Noise> = function(){
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
        case Held(ft):
          //trace("driver held");
          ft.handle(driver);
        default: trace("?");
      }
      //trace('HERE: $simplex');
    }
    driver(d);
  }
}