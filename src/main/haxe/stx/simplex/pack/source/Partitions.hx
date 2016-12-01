package stx.simplex.pack.source;

import stx.Chunk;
import stx.simplex.core.Data;
using stx.simplex.Package;

class Partitions{
  static public function slice<T>(pt:Partition<T>,fn:T->Bool):Partition<T>{
    return switch(pt){
      case Emit(head,tail) :
        switch(head){
          case Val(v) : 
            if(fn(v)){
              Emit(Nil,Emit(head,slice(tail,fn)));
            }else{
              Emit(head,slice(tail,fn)); 
            }
          case End(e) : 
            Emit(head,slice(tail,fn)); 
          case Nil    : 
            Emit(head,slice(tail,fn)); 
        }
      case Wait(arw)  :
        var lhs = arw;
        var rhs = slice.bind(_,fn);
        var co  = lhs.then(rhs);
        Wait(
          arw.then(slice.bind(_,fn))
        ); 
      case Held(ft)   : 
        Held(ft.map(slice.bind(_,fn))); 
      case Halt(e)    : 
        Halt(e);
    }
  }
}