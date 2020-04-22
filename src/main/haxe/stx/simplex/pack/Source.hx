package stx.simplex.pack;

typedef SourceDef<O,R,E> = SimplexSum<Noise,O,R,E>;

@:using(stx.simplex.pack.Source.SourceLift)
@:forward abstract Source<O,R,E>(SourceDef<O,R,E>) from SourceDef<O,R,E> to SourceDef<O,R,E>{
  static public var _(default,never) = SourceLift;
  @:noUsing static public function lift<O,R,E>(self:SourceDef<O,R,E>) return new Source(self);
  public function new(self) this = self;

  @:from static public function fromSimplex<O,R,E>(self:Simplex<Noise,O,R,E>):Source<O,R,E>{
    return lift(self);
  }
  @:to public function toSimplex():Simplex<Noise,O,R,E>{
    return this;
  }
}
class SourceLift{
    @:noUsing static private function lift<O,R,E>(self:SourceDef<O,R,E>) return Source.lift(self);

    static public function toEmiter<O,R,E>(self:Source<O,R,E>,cb:R->O):Emiter<O,E>{
      function recurse(self:Source<O,R,E>):Source<O,Noise,E>{
        var f = __.into(recurse);
        return switch(self){
          case Halt(Terminated(cause))  : __.term(cause);
          case Halt(Production(ret))    : __.stop().cons(cb(ret));
          case Emit(head,rest)          : __.emit(head,rest.mod(f));
          case Wait(arw)                : __.wait(arw.mod(f));
          case Hold(ft)                 : __.hold(ft.mod(f));
        } 
      }
      return Emiter.lift(recurse(self));
    }
    static public function filter<O,R,E>(self:Source<O,R,E>,fn:O->Bool):Source<O,R,E>{
      var f = __.into(filter.bind(_,fn));
      return lift(switch(self){
        case Emit(head,tail) : 
          if(fn(head)){
            __.emit(head,f(tail));
          }else{
            tail.mod(f);
          }
        case Wait(fn)        : __.wait(fn.mod(f));
        case Hold(ft)        : __.hold(ft.mod(f));
        case Halt(t)         : __.halt(t);
      });
    }
    static public function map_filter<T,U,R,E>(self:Source<T,R,E>,fn:T->Option<U>):Source<U,R,E>{
      var f = __.into(map_filter.bind(_,fn));
      return lift(switch(self){
        case Emit(head,tail) :
          switch(fn(head)){
            case None     : f(tail);
            case Some(v)  : __.emit(v,f(tail));
          } 
        case Wait(arw)       : __.wait(arw.mod(f));
        case Hold(ft)        : __.hold(ft.mod(f));
        case Halt(t)         : __.halt(t);
      });
    }
  }