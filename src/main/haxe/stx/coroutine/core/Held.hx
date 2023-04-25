package stx.coroutine.core;

typedef HeldDef<I,O,R,E> = ProvideDef<Coroutine<I,O,R,E>>;

@:using(eu.ohmrun.Fletcher.FletcherLift)
@:using(eu.ohmrun.fletcher.Provide.ProvideLift)
@:forward abstract Held<I,O,R,E>(HeldDef<I,O,R,E>) from HeldDef<I,O,R,E> to HeldDef<I,O,R,E>{
  public function new(self:HeldDef<I,O,R,E>) this = self;
  @:from static public function fromProvide<I,O,R,E>(self:Provide<Coroutine<I,O,R,E>>){
    return lift(self);
  }
  @:from static public function fromProduce<I,O,R,E>(self:Produce<Coroutine<I,O,R,E>,E>){
    return lift(
      Fletcher.Then(
        self,
        Fletcher.Sync(
          (res:Upshot<Coroutine<I,O,R,E>,E>) -> res.fold(
            ok -> ok,
            no -> __.exit(no)
          )
        )
      )
    );
  }
  @:from static public function fromProduceI<I,O,R,E>(self:Produce<Coroutine<I,O,R,E>,Noise>):Held<I,O,R,E>{
    return new Held(
      Provide.lift(
        Fletcher.Anon(
          (ipt:Noise,cont:Terminal<Coroutine<I,O,R,E>,Noise>) -> cont.receive(
            self.forward(Noise).fold_mapp(
              (ok) -> {
                //$type(ok);
                final result : CoroutineSum<I,O,R,E> = ok.fold(
                  x -> {
                    //$type(x);
                    function f(self:CoroutineSum<I,O,R,E>):Coroutine<I,O,R,E>{
                      return switch(self){
                        case Emit(o,next)                           : __.emit(o,__.hold(Held.Pause(f.bind(next))));
                        case Wait(tran)                             : __.wait(
                          (ctrl:Control<I>) -> switch(ctrl){
                            case Quit(None)     : __.stop();
                            case Quit(Some(e))  : f(tran(Control.quit(e))); 
                            case Push(i)        : f(tran(Control.push(i)));
                          }
                        );
                        case Hold(held)                             : 
                          final result = held.convert(f);
                       //   $type(result);
                          __.hold(
                            result
                          );
                        case Halt(Terminated(Exit(rejection)))      : 
                          final result = __.exit(rejection);
                         // $type(result);
                          result;
                        case Halt(Production(r))                    : __.prod(r);
                        case Halt(Terminated(Stop))                 : __.stop();
                      }
                    }
                    final result = f(x);
                    //$type(result);
                    result;
                  },
                  n -> {
                    //$type(n);
                    final result = __.exit(n.fault().explain(_ -> _.e_undefined()));//TODO what case is this?
                  //  $type(result);
                    result;
                  }//__.success(__.exit($type(n)))
                );
                //$type(result);
                __.success(result);
              },
              no -> {
                return __.failure(no);
              }
            )
          )
        )
      )
    );
  }
  @:noUsing static public function Ready<I,O,R,E>(data:Coroutine<I,O,R,E>,?pos:Pos){
    return Provide.pure(data);
  }
  @:noUsing static public function Guard<I,O,R,E>(guard:Future<Coroutine<I,O,R,E>>,?pos:Pos):Held<I,O,R,E>{
    return lift(Provide.fromFuture(guard));
  }
  @:noUsing static public function Pause<I,O,R,E>(self:Void->Coroutine<I,O,R,E>):Held<I,O,R,E>{
    return lift(Provide.fromFunXR(self));
  }
  @:noUsing static public function lift<I,O,R,E>(fn:HeldDef<I,O,R,E>):Held<I,O,R,E>{
    return new Held(fn);
  }
  @:to public function toCoroutine():Coroutine<I,O,R,E>{
    return Hold(this);
  }
  @:noUsing static public function pure<I,O,R,E>(spx:Coroutine<I,O,R,E>):Coroutine<I,O,R,E>{
    return __.hold(lift(Provide.pure(spx)));
  } 
  @:noUsing static public function lazy<I,O,R,E>(spx:Thunk<Coroutine<I,O,R,E>>):Coroutine<I,O,R,E>{
    return __.hold(lift(Provide.fromFunXR(spx.prj())));
  }
  public inline function mod<I1,O1,R1,E1>(fn:Coroutine<I,O,R,E>->Coroutine<I1,O1,R1,E1>):Held<I1,O1,R1,E1>{
    return new Held(Provide._.convert(this,fn));
  }
  public function touch(before:Void->Void,after:Void->Void):Held<I,O,R,E>{
    return lift(Fletcher._.mapi(
      this,
      ((_:Noise) -> before()).promote()
    ).map(
      ((_:Coroutine<I,O,R,E>) -> after()).promote()
    ));
  }
  public function environment(handler):Fiber{
    return Provide._.environment(this,handler);
  }
  public function convert<Z>(that:Convert<CoroutineSum<I,O,R,E>,Z>):Provide<Z>{
    return Provide._.convert(this,that);
  }
  public function toString():String{
    return 'HELD';
  }
}
class HeldLift{
  //static public function handle<I,O,R,E>(fn:Coroutine<I,O,R,E>->)
}