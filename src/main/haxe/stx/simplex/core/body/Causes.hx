package stx.simplex.core.body;

class Causes{
  static public function toOption(self:Cause):Option<stx.Error>{
    return switch(self){
      case Early(err)     : Some(err);
      case Kill           : Some(new Error(500,"Kill"));
    }
  }
  static public function next(thiz:Cause,that:Cause):Cause{
    return switch([thiz,that]){
      case [Kill,Kill]                  : Kill;
      case [Early(e0),Early(e1)]        : Early(e0.next(e1));
      case [Early(err),_]               : Early(err);
      case [_,Early(err)]               : Early(err);
    }
  }
}