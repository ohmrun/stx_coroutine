package stx.simplex.core.body;

class Causes{
  static public function toOption(self:Cause):Option<Error>{
    return switch(self){
      case Early(err)     : Some(err);
      case Stop           : Some(new Error(500,"Stop"));
    }
  }
  static public function next(thiz:Cause,that:Cause):Cause{
    return switch([thiz,that]){
      case [Stop,Stop]                  : Stop;
      case [Early(e0),Early(e1)]        : Early(e0.next(e1));
      case [Early(err),_]               : Early(err);
      case [_,Early(err)]               : Early(err);
    }
  }
}