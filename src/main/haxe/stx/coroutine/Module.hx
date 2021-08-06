package stx.coroutine;

class Module extends Clazz{
  public function failure(){
    return new stx.coroutine.Failure();
  }
}