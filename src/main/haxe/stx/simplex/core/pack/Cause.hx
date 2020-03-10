package stx.simplex.core.pack;

import stx.simplex.core.head.Data.Cause in CauseT;
import stx.simplex.core.body.Causes;

/**
 *  Specifies the Cause of a Return if not a Production.
 */
abstract Cause(CauseT) from CauseT to CauseT{
  public function new(self){
    this = self;
  }
  public function next(that){
    return Causes.next(this,that);
  }  
  public function toOption():Option<Error>{
    return Causes.toOption(this);
  }
  @:from static public function fromTinkError(e:tink.Error):Cause{
    return Early(Error.fromTinkError(e));
  }
  @:from static public function fromError(e:Error):Cause{
    return Early(e);
  }
  static public function early(e:Error):Cause{
    return Early(e);
  }
} 