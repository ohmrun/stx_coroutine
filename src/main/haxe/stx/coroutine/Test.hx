package stx.coroutine;


using stx.unit.Test;

using stx.Coroutine;

class Test{
  static public function main(){
    __.unit([
        new LatchTest(),
      ],
      []
    );
  }
}
class LatchTest extends TestCase{
  public function test(){
      
  }
}
class EmiterTest extends TestCase{

}