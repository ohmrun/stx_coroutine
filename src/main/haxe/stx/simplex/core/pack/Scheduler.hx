package stx.simplex.core.pack;

class Scheduler{
  var timeout : Float;
  var maximum : Float;
  public function new(timeout = 10.0,maximum = 2.0){
    this.timeout = timeout;
    this.maximum = maximum;
  }
  public function iterator():Iterator<Float>{
    return new Schedule(timeout,maximum);
  }
}