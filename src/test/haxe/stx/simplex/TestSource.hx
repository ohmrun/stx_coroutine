package stx.simplex;

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
            //o.push(x);
            return Resume;
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
          return Resume;
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
    //b.pipeTo(printer());
  }
}