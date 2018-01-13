package stx.simplex.pack;

import stx.simplex.body.Effects;
import stx.simplex.head.Data.Effect in EffectT;

abstract Effect(EffectT) from EffectT to EffectT{
    public function new(self){
        this = self;
    }
    public function run(){
        return Effects.run(this);
    }
}