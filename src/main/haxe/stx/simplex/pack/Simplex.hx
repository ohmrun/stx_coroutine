package stx.simplex.pack;

import haxe.ds.Option;

import tink.CoreApi;

import thx.Options;

using stx.Pointwise;

import stx.data.Thunk;
import stx.data.Sink;

using stx.async.arrowlet.Package;

import stx.simplex.core.Data;

using stx.simplex.Package;

import stx.simplex.core.data.Simplex in SimplexT;

typedef Fn<I,O> = I -> O;

@:forward abstract Simplex<I,O,R>(SimplexT<I,O,R>) from SimplexT<I,O,R> to SimplexT<I,O,R>{
  public function new(v){
    this = v;
  }
  @:from static public function fromFunction<I,O>(fn:I->O):Simplex<I,O,Noise>{
    var method :Fn<Control<I>,Simplex<I,O,Noise>>= null;
        method = function(i:Control<I>){
          return switch(i){
            case Continue(v) :
              var o : Simplex<I,O,Noise> = null;
              try{
                o = Emit(fn(v),Wait(method));
              }catch(e:stx.Error){
                o = Halt(Terminated(Early(e)));
              }catch(e:tink.core.Error){
                o = Halt(Terminated(Early(stx.Error.fromTinkError(e))));
              }catch(e:Dynamic){
                o = Halt(Terminated(Early(new stx.Error(500,e))));
              }
              o;
            case Discontinue(cause) : 
              Halt(Terminated(cause));
          }
      };
    return Wait(method);
  }
  /*
  @:from static public function fromArrow<I,O,R>(arw:Arrowlet<I,O>):Simplex<I,O,Error>{
    return Wait(
      function rec(v:I){
        return Held(arw.then(Emit.bind(_,Wait(rec))).apply(v));
      }
    );
  }*/
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
  public function push(p:I):Simplex<I,O,R>{
    return Simplexs.push(this,p);
  }
  public function tapI<I>(fn:Control<I>->Void){
    return Simplexs.tapI(this,fn);
  }
  public function mergeWith(that:Simplex<I,O,R>, merger:R->R->R):Simplex<I,O,R>{
    return Simplexs.mergeWith(this,that,merger);
  }
}
