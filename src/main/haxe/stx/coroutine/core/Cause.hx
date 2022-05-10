package stx.coroutine.core;

enum CauseSum<E>{
  Stop;
  Exit(err:Refuse<E>);
  //Timeout();
}

/**
 *  Specifies the Cause of a Return if not a Production.
 */
@:using(stx.coroutine.core.Cause.CauseLift)
abstract Cause<E>(CauseSum<E>) from CauseSum<E> to CauseSum<E>{
  public function new(self){
    this = self;
  }
  //   return Exit(Refuse.fromTinkRefuse(e));
  // }
  @:from static public function fromRefuse<E>(e:Refuse<E>):Cause<E>{
    return Exit(e);
  }
  static public function early<E>(e:Refuse<E>):Cause<E>{
    return Exit(e);
  }
} 
class CauseLift{
  static public function toOption<E>(self:Cause<E>):Option<Refuse<E>>{
    return switch(self){
      case Exit(err)      : Some(err);
      case Stop           : Some(__.fault().explain(_ -> stx.coroutine.core.Errors.e_coroutine_stop(_)));
    }
  }
  static public function next<E>(thiz:Cause<E>,that:Cause<E>):Cause<E>{
    return switch([thiz,that]){
      case [Stop,Stop]                  : Stop;
      case [Exit(e0),Exit(e1)]          : Exit(e0.concat(e1));
      case [Exit(err),_]                : Exit(err);
      case [_,Exit(err)]                : Exit(err);
    }
  }
}