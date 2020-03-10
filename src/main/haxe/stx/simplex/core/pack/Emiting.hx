package stx.simplex.core.pack;

import stx.simplex.core.head.data.Emiting in EmitingT;

@:forward abstract Emiting<I,O,R>(EmitingT<I,O,R>) from EmitingT<I,O,R>{
  public function new(self){
    this = self;
  }
  static public function create<I,O,R>(o:O,next:Simplex<I,O,R>):Emiting<I,O,R>{
    return new EmitingT(next,o);
  }
  @:to public function toSimplex<I,O,R>():Simplex<I,O,R>{
    return Emit(this);
  }
}