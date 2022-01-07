package stx.coroutine.core;

class ECoroutineStop extends Digest{
  public function new(){
    super('01FRQ77KZBWH5B94085CX40Y02','Coroutine stopped.');
  }
}
class ECoroutineInputHung extends Digest{
  public function new(){
    super("01FRSGYFNGNMAKJT12C1GSM2Y4","Input hung");
  }
}
class ECoroutineProvidedValueToStoppedCoroutine extends Digest{
  public function new(){
    super("01FRSHA2FF3J3MEE5AF9RJ5YE7","Provided value to stopped coroutine");
  }
}
class Errors{
  static public function e_coroutine_stop(digests:Digests):Digest{
    return new ECoroutineStop();
  }
  static public function e_coroutine_provided_value_to_stopped_coroutine(digests:Digests):Digest{
    return new ECoroutineProvidedValueToStoppedCoroutine();
  }
}