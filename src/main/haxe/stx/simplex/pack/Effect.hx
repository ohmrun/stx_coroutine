package stx.simplex.pack;

import stx.simplex.body.Producers;
import stx.simplex.body.Effects;
import stx.simplex.head.Data.Effect in EffectT;

@:forward abstract Effect(EffectT) from EffectT to EffectT{
  @:from static public function fromInterface(i:Interface<Noise,Noise,Noise>):Effect{
    return new Effect(i);
  }
  @:from static public function fromSimplex(i:Simplex<Noise,Noise,Noise>):Effect{
    return new Effect(i);
  }
  @:to public function toInterface():Interface<Noise,Noise,Noise>{
    return this;
  }
  public function new(self){
    this = self;
  }
  public function run(?schedule){
    return Effects.run(this,schedule);
  }
  public function causeLater(c:Cause){
    return Effects.causeLater(this,c);
  }
}