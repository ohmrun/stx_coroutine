package stx.simplex.core.pack;

class Schedule{
  var base           : Float;
  var idx            : Int;

  public var initiated      : Bool;
  public var timestamp      : Float;
  public var timeout        : Float;
  public var maximum        : Float;

  public function new(timeout,maximum){
    this.idx      = 0;
    this.base     = 0.3;
    this.timeout  = timeout == null ? Math.POSITIVE_INFINITY : timeout;
    this.maximum  = maximum == null ? Math.POSITIVE_INFINITY : timeout;
  }
  function stamp(){
    return haxe.Timer.stamp();
  }
  function duration(){
    return stamp() - timestamp;
  }
  function init(){
    if(!initiated){
      initiated = true;
      timestamp = stamp();
    }
  }
  public function next():Float{
    init();
    idx = idx + 1;
    var time = (idx * base) * (idx * base);
        time = maximum < time ? maximum : time; 
    return time;
  }
  public function hasNext():Bool{
    init();
    return duration() <= timeout;
  }
}