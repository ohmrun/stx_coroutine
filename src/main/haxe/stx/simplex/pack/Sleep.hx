package stx.simplex.pack;

@:forward abstract Sleep(Effect) from Effect to Effect{
  public function new(?schedule:Iterator<Float>){
    var schedule = schedule == null ? new Scheduler().iterator() : schedule;
    this = Emiters.fromIterator(schedule).map(
      (x) -> {
        Sys.sleep(x);
        Noise;
      }
    );
  }
  public function toEffect():Effect{
    return this;
  }
}