package stx.simplex.core.pack;

import stx.simplex.core.head.Data.State in StateT;
import stx.simplex.core.head.data.Simplex in SimplexT;
import stx.simplex.core.head.data.Interface in InterfaceT;
import stx.simplex.core.body.Simplexs;

@:forward abstract Simplex<I,O,R>(InterfaceT<I,O,R>) from InterfaceT<I,O,R> to InterfaceT<I,O,R>{
  @:from static public function fromSimplexT<I,O,R>(spx:SimplexT<I,O,R>):Simplex<I,O,R>{
    return new Simplex(spx);
  }
  @:from static public function fromState<I,O,R>(state:State<I,O,R>):Simplex<I,O,R>{
    return new SimplexT(state);
  }
  @:from static public function fromStateT<I,O,R>(state:StateT<I,O,R>):Simplex<I,O,R>{
    return new SimplexT(state);
  }
  public function new(v){
    this = v;
  }
  public function held(){
    return switch(this.state){
      case Hold(_)  : true;
      default       : false; 
    }
  }
  public function cons(v:O):Simplex<I,O,R>{
    return Simplexs.cons(this,v);
  }
  public function seek(advice:Advice):Simplex<I,O,R>{
    return Simplexs.seek(this,advice);
  }
  public function pipe<O2>(that:Simplex<O,O2,R>):Simplex<I,O2,R>{
    return Simplexs.pipe(this,that);
  }
}