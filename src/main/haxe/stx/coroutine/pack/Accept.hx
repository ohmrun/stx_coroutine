package stx.coroutine.pack;

typedef AcceptDef<I,E> = CoroutineSum<I,Noise,Noise,E>;

@:forward abstract Accept<I,E>(AcceptDef<I,E>) from AcceptDef<I,E> to AcceptDef<I,E>{
    static public function lift<I,E>(self:AcceptDef<I,E>):Accept<I,E> return new Accept(self);
    public function new(self) this = self;
    
    @:noUsing static public function handler<O,E>(fn:O->Void):Accept<O,E>{
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
    public function provide(v:I):Accept<I,E>{
      return lift(Coroutine._.provide(this,v));
    }
    @:from static public function fromHandler<I,E>(fn:I->Void):Accept<I,E>{
        return handler(fn);
    }
    @:to public function toCoroutine():Coroutine<I,Noise,Noise,E>{
      return this;
    } 
    @:from static public function fromCoroutine<I,E>(self:Coroutine<I,Noise,Noise,E>):Accept<I,E>{
      return lift(self);
    }
}