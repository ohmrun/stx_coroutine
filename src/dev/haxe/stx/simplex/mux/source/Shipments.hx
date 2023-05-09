package stx.coroutine.pack.source;

import stx.Chunk;
import stx.coroutine.core.Data;
using stx.coroutine.Package;

class Shipments{
  static public function slice<T>(pt:Shipment<T>,fn:T->Bool):Shipment<T>{
    function recurse(pt:Coroutine<Nada,Either<Chunk<T>,Chunk<T>>,Nada>){
      return switch(pt){
        case Emit(head,tail) :
          switch(head){
            case Left(Val(v)) : 
              if(fn(v)){
                Emit(Right(Val(v)),Emit(Right(Nil),recurse(tail)));
              }else{
                Emit(Right(Val(v)),recurse(tail)); 
              }
            case Left(End(e)) : 
              Emit(Right(End(e)),recurse(tail)); 
            case Left(Nil)    : 
              Emit(Right(Nil),recurse(tail));
            case Right(v)     : Emit(Right(v),recurse(tail)); 
          }
        case Wait(arw)  : recurse(arw(Nada));
        case Hold(ft)   : Hold(ft.map(recurse)); 
        case Halt(e)    : Halt(e);
      }
    }
    var before    = pt.map(Left);
    var process   = recurse(before);
    var filtered  = process.mapFilter(
      function(x){
        return switch(x){
          case Left(v)  : None;
          case Right(v) : Some(v);
        }
      }
    );
    return filtered;
  }
}