package stx.simplex.core.pack;

import stx.simplex.core.head.data.Advice in AdviceT;

abstract Advice(AdviceT) from AdviceT{
  public function new(self){
    this = self;
  }
}