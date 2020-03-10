package stx.ui;

import stx.Module;

#if (js && !nodejs)
class Window{
  public function new(m:Module){
    this.mouse = new Mouse(m);
  }
  public var mouse : Mouse;
}
#end