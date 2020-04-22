package stx.simplex;

import utest.Assert in Rig;
import utest.Async;
import utest.Test;

using stx.simplex.Pack;

class Test{
  static public function main(){
    utest.UTest.run([
      new MergeTest(),
    ]);
  }
}
class MergeTest extends utest.Test{
  public function testWork(){
    
  }
  public function merger_maker<I,O,R,E>():Simplex<I,O,R,E>->Simplex<I,O,R,E>->Simplex<I,O,R,E>{
    var l_stat = new Stat();
    var r_stat = new Stat();
    return (lhs:Simplex<I,O,R,E>,rhs:Simplex<I,O,R,E>) -> {
      return switch([lhs,rhs]){
        case [Halt(_),_]              : lhs;
        case [_,Halt(_)]              : rhs;
        default                       : 
          l_stat.value() < r_stat.value() ? lhs.touch(lhs.enter,lhs.leave) : rhs.touch(rhs.enter,rhs.leave);
      }    
    };
  }
}
class Stat{
  private var clock(default,null):Clock;

  public function new(clock:Clock){
    this.clock            = clock;
    this.accessed         = 1;
    this.total_runtime    = 1;
    this.total_waiting    = 1;
  }
  var last_access(default,null)    : Null<Seconds>;
  var last_runtime(default,null)   : Null<Seconds>;
  var last_waiting(default,null)   : Null<Seconds>;
  
  var total_waiting(default,null)  : Seconds;
  var total_runtime(default,null)  : Seconds;

  var accessed(default,null)       : Int;

  public function enter(){
    this.accessed = this.accessed + 1;
    if(this.last_access != null){
      this.last_waiting   = clock.pure(this.last_access + this.last_runtime).delta();
      this.total_waiting  = this.total_waiting + this.last_waiting;
    }
    this.last_access  = clock.stamp();
  }
  public function leave(){
    this.last_runtime = clock.pure(last_access).delta();
    total_runtime     = last_runtime + total_runtime;
  }
  public function value():Float{
    //trace('$total_waiting $total_runtime');
    var a           = (total_waiting / total_runtime );
    var b : Seconds = accessed + 1;
    var c           = a * b;
    var d           = @:privateAccess c.prj();
    return d;
  }
}