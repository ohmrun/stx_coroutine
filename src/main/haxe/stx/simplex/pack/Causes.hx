package stx.simplex.pack;

class Causes{
  static public function toOption(self:Cause):Option<stx.Error>{
    return switch(self){
      case Early(err) : Some(err);
      case Kill       : Some(new Error(500,"Kill"));
      case Finished   : None;
    }
  }
}