package stx.simplex.pack;

@:forward abstract Lazy<O>(Pipe<Pull,O>) from Pipe<Pull,O> to Pipe<Pull,O>{
  public function new(self){
    this = self;
  }
}