package stx.coroutine.pack;

typedef SinkDef<I,E> = CoroutineSum<I,Noise,Noise,E>;

@:forward abstract Sink<I,E>(SinkDef<I,E>) from SinkDef<I,E> to SinkDef<I,E>{
    static public function lift<I,E>(self:SinkDef<I,E>):Sink<I,E> return new Sink(self);
    public function new(self) this = self;
    
    @:noUsing static public function handler<O,E>(fn:O->Void):Sink<O,E>{
      return lift(__.wait(
          Transmission.fromFun1R(
            function rec(o){
              fn(o);
              return __.wait(Transmission.fromFun1R(rec));
            }
          )
      ));
    }
    @:noUsing static public function nowhere(){
        return handler((x)-> {});
    }
    public function provide(v:I):Sink<I,E>{
      return lift(Coroutine._.provide(this,v));
    }
    @:from static public function fromHandler<I,E>(fn:I->Void):Sink<I,E>{
        return handler(fn);
    }
    @:to public function toCoroutine():Coroutine<I,Noise,Noise,E>{
      return this;
    } 
    @:from static public function fromCoroutine<I,E>(self:Coroutine<I,Noise,Noise,E>):Sink<I,E>{
      return lift(self);
    }
}