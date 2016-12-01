package stx.simplex.pack;

import stx.simplex.core.Data.Cause in CauseT;

abstract Cause(CauseT) from CauseT to CauseT{
  public function new(self){
    this = self;
  }
  public function next(that:Cause):Cause{
    return switch([this,that]){
      case [Kill,Kill]              : Kill;
      case [Kill,Finished]          : Kill;
      case [Finished, Kill]         : Kill;
      case [Finished, Finished]     : Finished;
      case [Early(e0),Early(e1)]    : Early(e0.next(e1));
      case [Early(err),_]           : Early(err);
      case [_,Early(err)]           : Early(err);
    }
  }
} 