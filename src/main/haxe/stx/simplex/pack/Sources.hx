package stx.simplex.pack;

using stx.Tuple;
using stx.simplex.pack.Util;
using stx.Pointwise;

import stx.simplex.core.Data;
using stx.simplex.Package;

class Sources{
  static public function flatMap<T,U>(source:Source<T>,fn:T->Pipe<Noise,U>):Source<U>{
    var fn0 : T -> Pipe<Noise,U> = fn;
    return new Source(Pipes.flatMap(source,fn0));
  }
  static public function foldLeft<T,U>(source:Source<T>,fn:T->U->U,memo:U):Conclude<U>{
    return switch(source){
      case Emit(head,tail)                      : foldLeft(tail,fn,fn(head,memo));
      case Halt(Production(Noise))              : Halt(Production(memo));
      case Halt(Terminated(Finished))           : Halt(Production(memo));
      case Halt(Terminated(cause))              : Halt(Terminated(cause));
      case Wait(arw)                            : Wait(arw.then(foldLeft.bind(_,fn,memo)));
      case Held(ft)                             : Held(ft.map(foldLeft.bind(_,fn,memo)));
    }
  }
  /**
    Pulls on the left when the right is Held
  **/
  static public function receive<T,U>(self:Source<T>,that:Source<U>):Source<Either<T,U>>{
    return switch([self,that]){
      case [Emit(lhead,ltail),Emit(rhead,rtail)] : Emit(Left(lhead),Emit(Right(rhead),receive(ltail,rtail)));
      case [Wait(larw),Wait(rarw)]               : Wait(
        function(ctrl:Control<Noise>):Simplex<Noise,Either<T,U>,Noise>{
          return ctrl.lift(
            function(_){
              return receive(larw(Continue(Noise)),rarw(Continue(Noise)));
            }
          );
        }
      );
      case [Held(lft),Held(rft)]                 :
        Held(
          Util.eitherOrBoth(lft,rft).map(
            function(e){
              return switch(e){
                case Left(Left(l))        : receive(l,Held(rft)); //always pulls on the left when the right is waiting.
                case Left(Right(r))       : receive(Held(lft),r);
                case Right(tuple2(l,r))   : receive(l,r);
              }
            }
          )
        );
      default : Halt(Terminated(Finished));
    }
  }
  /**
    When the right is Held, waits for resolution before pulling from the left.
  */
  static public function deliver<T,U>(self:Source<T>,that:Source<U>):Source<Either<T,U>>{
    return switch([self,that]){
      case [Emit(lhead,ltail),Emit(rhead,rtail)] : Emit(Left(lhead),Emit(Right(rhead),deliver(ltail,rtail)));
      case [Wait(larw),Wait(rarw)]               : Wait(
        function(ctrl:Control<Noise>):Simplex<Noise,Either<T,U>,Noise>{
          return ctrl.lift(
            function(_){
              return deliver(larw(Continue(Noise)),rarw(Continue(Noise)));
            }
          );
        }
      );
      case [Held(lft),Held(rft)]                 :
        Held(
          Util.eitherOrBoth(lft,rft).flatMap(
            function(e){
              return switch(e){
                case Left(Left(l))        : rft.map(
                  deliver.bind(l)
                );
                case Left(Right(r))       : Future.sync(deliver(Held(lft),r));
                case Right(tuple2(l,r))   : Future.sync(deliver(l,r));
              }
            }
          )
        );
      default : Halt(Terminated(Finished));
    }
  }
  /*
  static public function share<T,U>(self:Source<T>):Tuple2<Source<T>,Source<T>>{
    var first   = self.toStream();
    return null; 
  }*/
  /*
  static public function determine(self:Source<T>,that:Source<U>):Source<Either<T,U>>{

  }*/
  static public function emiting<T,U>(self:Source<T>,that:Source<U>):Status{
    return switch([self,that]){
      case [Emit(_,_), Emit(_,_)]   : SBoth;
      case [Emit(_,_), _]           : SLeft;
      case [_,Emit(_,_)]            : SRight;
      case [_,_]                    : SNeither; 
    }
  }
  static public function waiting<T,U>(self:Source<T>,that:Source<U>):Status{
    return switch([self,that]){
      case [Wait(_), Wait(_)]       : SBoth;
      case [Wait(_), _]             : SLeft;
      case [_,Wait(_)]              : SRight;
      case [_,_]                    : SNeither; 
    }
  }
  static public function mapFilter<T,U>(src:Source<T>,fn:T->Option<U>):Source<U>{
    return switch(src){
      case Emit(head,tail) :
        switch(fn(head)){
          case None     : mapFilter(tail,fn);
          case Some(v)  : Emit(v,mapFilter(tail,fn));
        } 
      case Wait(arw)       : Wait(arw.then(mapFilter.bind(_,fn)));
      case Held(ft)        : Held(ft.map(mapFilter.bind(_,fn)));
      case Halt(t)         : Halt(t);
    }
  }
  static public function pipeTo<T>(src:Source<T>,fn:T->Void):Future<Cause>{
    var t = Future.trigger();
    function handler(v){
      switch(v){
        case Emit(head,tail)            : fn(head); handler(tail);
        case Wait(fn)                   : handler(fn(Noise));
        case Held(ft)                   : ft.handle(handler);
        case Halt(Terminated(cause))    : t.trigger(cause);
        case Halt(Production(Noise))    : t.trigger(Finished); 
      }
    }
    handler(src);
    return t.asFuture();
  }
}

enum Status{
  SLeft;
  SRight;
  SBoth;
  SNeither;
}