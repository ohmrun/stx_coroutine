package stx.simplex.core.pack;

import stx.simplex.core.head.Data.Simplex in SimplexT;
import stx.simplex.core.body.Simplexs;

typedef Fn<I,O> = I -> O;


@:forward abstract Simplex<I,O,R>(SimplexT<I,O,R>) from SimplexT<I,O,R> to SimplexT<I,O,R>{
  static public function hold<I,O,R>(held:Held<I,O,R>):Simplex<I,O,R>{
    return Hold(held);
  }
  static public function wait<I,O,R>(fn:Control<I> -> Simplex<I,O,R>):Simplex<I,O,R>{
    return Wait(fn);
  }
  public function new(v){
    this = v;
  }
  public function map<O0>(fn:O->O0):Simplex<I,O0,R>{
    return Simplexs.map(this,fn);
  }
  public function mapI<I1>(fn:I1->I):Simplex<I1,O,R>{
    return Simplexs.mapI(this,fn);
  }
  public function mapR<R,R1>(fn:R->R1):Simplex<I,O,R1>{
    return Simplexs.mapR(this,fn);
  }
  public function flatMapR<R2>(fn:R->Simplex<I,O,R2>):Simplex<I,O,R2>{
    return Simplexs.flatMapR(this,fn);
  }
  public function provide(p:I):Simplex<I,O,R>{
    return Simplexs.provide(this,p);
  }
  public function tapI(fn:Control<I>->Void){
    return Simplexs.tapI(this,fn);
  }
  public function tapO(fn:O->Void){
    return Simplexs.tapO(this,fn);
  }
  public function tapR(fn:Return<R>->Void){
    return Simplexs.tapR(this,fn);
  }
  public function mergeWith(that:Simplex<I,O,R>, merger:R->R->R):Simplex<I,O,R>{
    return Simplexs.mergeWith(this,that,merger);
  }
  public function pipe<O2,R>(prc1:Simplex<O,O2,R>):Simplex<I,O2,R>{
    return Simplexs.pipe(this,prc1);
  }
}
