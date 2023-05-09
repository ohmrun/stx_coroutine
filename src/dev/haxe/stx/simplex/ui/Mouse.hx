package stx.ui;

import stx.Module;
import stx.types.Tuple2;
import tink.core.Signal;
using stx.async.Futures;
using stx.async.Arrowlet;
import stx.types.Producer;
import stx.pico.Nada;

#if js
  #if(!nodejs)
    import stx.async.arrowlet.js.JQueryEvent;
    import js.Browser;
    import js.JQuery;
    import js.JQuery.JQueryHelper.*;
  #end
#end
#if js
  #if(!nodejs)
class Mouse{
  public function new(module:Module){
    var sig = Signal.trigger();
        J(Browser.window).on('mousemove',
          function(evt){
            sig.trigger({ x : evt.pageX, y : evt.pageY});
          }
        );
    var md = Signal.trigger();
        J(Browser.window).on('mousedown',
          function(evt){
            md.trigger(tuple2(MouseDown,{x : evt.pageX, y : evt.pageY}));
          }
        );
    var mu = Signal.trigger();
        J(Browser.window).on('mouseup',
          function(evt){
            mu.trigger(tuple2(MouseUp,{x : evt.pageX, y : evt.pageY}));
          }
        );
    this.click    = md.asSignal().join(mu);
    this.position = sig;
  }
  public var position : Signal<Position>;
  public var click    : Signal<Click>;
}

typedef Position = { x : Int, y : Int };

typedef Click = Tuple2<ClickState,Position>;

enum ClickState{
  MouseDown;
  MouseUp;
}
#end
#end