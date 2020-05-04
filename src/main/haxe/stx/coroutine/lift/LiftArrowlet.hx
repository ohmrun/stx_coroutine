class LiftArrowlet{
  static public function asTunnel<I,O>(arw:Arrowlet<I,O>):Tunnel<I,O>{
      return stx.coroutine.body.Tunnels.fromArrowlet(arw);
  }