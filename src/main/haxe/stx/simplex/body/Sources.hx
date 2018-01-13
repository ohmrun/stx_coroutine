package stx.simplex.body;


class Sources{
  static public function emiting<T,U,R>(self:Source<T,R>,that:Source<U,R>):Status{
    return switch([self,that]){
      case [Emit(_,_), Emit(_,_)]   : SBoth;
      case [Emit(_,_), _]           : SLeft;
      case [_,Emit(_,_)]            : SRight;
      case [_,_]                    : SNeither; 
    }
  }
  static public function waiting<T,U,R>(self:Source<T,R>,that:Source<U,R>):Status{
    return switch([self,that]){
      case [Wait(_), Wait(_)]       : SBoth;
      case [Wait(_), _]             : SLeft;
      case [_,Wait(_)]              : SRight;
      case [_,_]                    : SNeither; 
    }
  }
  static public function filter<O,R>(self:Source<O,R>,fn:O->Bool):Source<O,R>{
    return switch(self){
      case Emit(head,tail) : 
        if(fn(head)){
          Emit(head,filter(tail,fn));
        }else{
          filter(tail,fn);
        }
      case Wait(fn)        : Wait(fn);
      case Hold(ft)        : Hold(ft);
      case Halt(t)         : Halt(t);
    }
  }
  static public function mapFilter<T,U,R>(src:Source<T,R>,fn:T->Option<U>):Source<U,R>{
    return switch(src){
      case Emit(head,tail) :
        switch(fn(head)){
          case None     : mapFilter(tail,fn);
          case Some(v)  : Emit(v,mapFilter(tail,fn));
        } 
      case Wait(arw)       : Wait(arw.then(mapFilter.bind(_,fn)));
      case Hold(ft)        : Hold(ft.map(mapFilter.bind(_,fn)));
      case Halt(t)         : Halt(t);
    }
  }
  /*
  static public function flatMap<O,O2,R>(prc:Source<O,R>,fn:O->Source<O2,R>):Source<O2,R>{
    return switch (prc){
      case Emit(head,tail)  : append(fn(head),Pointwise.toThunk(flatMap(tail,fn)));
      case Wait(arw)        : Wait(
        function(i){
          var next = arw(i);
          return flatMap(next,fn);
        }
      );
      case Halt(e)          : Halt(e);
      case Hold(ft)         : Hold(ft.map(flatMap.bind(_,fn)));
    }
  }
  static public function append<O,R>(prc0:Source<O,R>,prc1:Thunk<Source<O,R>>):Source<O,R>{
    return switch (prc0){
      case Emit(head,tail)              : Emit(head,append(tail,prc1));
      case Wait(arw)                    : Wait(arw.then(append.bind(_,prc1)));
      case Halt(Terminated(Finished))   : prc1();
      case Halt(Production(Noise))      : prc1();
      case Halt(Terminated(cause))      : Halt(Terminated(cause));
      case Hold(ft)                     : Hold(ft.map(append.bind(_,prc1)));
    }
  }
  static public function cons<O,R>(prc0:Source<O,R>,v:O):Source<O,R>{
    return append(Halt(Terminated(Clean)),prc0);
  }*/
}

enum Status{
  SLeft;
  SRight;
  SBoth;
  SNeither;
}