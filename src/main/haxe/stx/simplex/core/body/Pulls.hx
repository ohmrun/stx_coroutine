package stx.simplex.core.body;

import tink.core.Callback;

class Pulls{

  static public function amb<I,O,R>(l:Pull<I,O,R>,r:Pull<I,O,R>):Either<Pull<I,O,R>,Pull<I,O,R>>{
    var rnd = function(l,r){
      return Math.random() - 0.5 >= 0 ? Left(l) : Right(r);
    }
    return rnd(l,r);
  }
  // static public function pull<A,I,O,R>(l:Pull<I,O,R>,r:Pull<I,O,R>):Emiter<Pull<I,O,R>> {
  //   return switch([l,r]){
  //     case [l,r] if(l.ready() && r.ready()) : 
  //       Emit(l,Emit(r,Constructors.done(Noise)));
  //     case  
  //   }
  // }
  static public function press<I,O,R>(p:Pull<I,O,R>):Pull<I,O,R>{
    return switch(p){
      case Hung(l) if (l.report() == Latent) : Hung(l.press());
      default : p;
    }
  }
}