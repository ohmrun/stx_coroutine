package stx.simplex;

using utest.Assert;

import stx.simplex.core.pack.Operator;
import stx.simplex.core.pack.Op;
import stx.simplex.core.head.data.State;
import stx.simplex.core.head.data.Advice;
import stx.simplex.core.head.data.Control;

import stx.simplex.core.pack.Emission;
import stx.simplex.core.pack.Simplex;

import stx.simplex.core.body.Simplexs;

class TestSimplex extends utest.Test{
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
  // public function testFeedDrive(){
  //   trace('testFeedDrive');
  //   var driver = Generator.stream(
  //     () -> {
  //       trace('gen');
  //       return Future.sync(Data(Noise));
  //     }
  //   );
    
  //   var a = Wait(
  //     Emission.pure(
  //       (i) -> Emit(i+1,
  //         Wait(
  //           (ctl) -> ctl.lift( 
  //             (i) -> Emit(i + 994,Constructors.bang())
  //           )
  //         )
  //       )
  //     )
  //   ).upcast().asPipe();//.tap((i)-> trace(i));

  //   var p = [10,11].toEmiter();//.tap((i) -> trace(i));
  //   var b = a.fill(p);//.tap((i)->trace(i));
  //   var d = b.reduce((next,memo) -> memo + next,100);//.tap((i) -> trace(i));
  //   var e = d.complete((i) -> trace(i));
  //   var f = e.drive(driver);
  //       f.handle((i)-> trace(i));
  // }
  public function testProvide(){
      var a = function rec(op:Operator<Int>):Simplex<Int,Int,Noise>{
        return switch(op(Op.okay())){
          case Push(v)  : Spx.wait(rec).cons(v);
          default       : Spx.wait(rec);
        }
      }
      var b = Spx.wait(new Emission(a));
      var c = Simplexs.provide(b,100);
      
      var n   = 0;
      var arr = [];
      function handler(v:Simplex<Int,Int,Noise>){
        switch(v.state){
          case Wait(fn) if(n<5) : 
            var next = fn(Operator.pusher(n));
            n++;
            handler(next);
          case Hold(ft) :
            ft().handle(handler);
          case Emit(emit) :
            arr.push(emit.data);
            handler(emit.next);
          default : 
        }
      }
      handler(c);
      arr.same([100,0,1,2,3,4]);      
  }
  public function testPipe(){
    var l = Spx.emit(1,Spx.stop());
    var r = Spx.wait(
      (v:Int) -> {
        Spx.emit(v+1,Spx.stop());
      }
    );

    var f = l.pipe(r);

    function handler(spx:Simplex<Noise,Int,Noise>){
      switch(spx.state){
        case Wait(arw) : handler(arw(Operator.unit()));
        case Emit(e)   :
          e.data.equals(2); 
          handler(e.next);
        case Seek(_,n) : handler(n);
        default:
      }
    }
    handler(f);
  }
}