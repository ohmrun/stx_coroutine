package stx.simplex;


import stx.simplex.parser.Produce;
import stx.simplex.parser.Seq;
import stx.simplex.parser.Sequable;
import stx.simplex.data.Simplex;

import stx.simplex.parser.data.*;
import stx.simplex.parser.data.Produce;
import stx.simplex.parser.Produce;

typedef ParserT<I,O> = stx.Simplex<Seq<I>,Needed,Produce<Seq<I>,Seq<O>>>;

@:forward abstract Parser<I,O>(ParserT<I,O>) from ParserT<I,O> to ParserT<I,O>{
  public function new(self){
    this = self;
  }
}
class ParserTest{
  public function new(){}
}
class Parsers{
  static public function zero<I,O>():Parser<I,O>{
    return Wait(
      function(v:Seq<I>){
        return Halt(Produce.pure(v));
      }
    );
  }
  static public function predicate<I>(fn:I->Bool):Parser<I,I>{
    return Wait(
      function(ipt:Seq<I>){
        var value = ipt.peek();
        var out : Seq<I>  = Seq.zero();
        if(fn(value)){
          ipt.next();
          out = Seq.pure(value);
        }
        return Halt(Produce.create(ipt,out));
      }
    );
  }
  static public function any<I>():Parser<I,I>{
    return predicate(
      function(i){ return true; }
    );
  }
  static public function exactly(str:String):Parser<String,String>{
    return predicate(
      function(i:String){
        return i == str;
      }
    );
  }
  static public function then<I,O,R>(prs:Parser<I,O>,fn:O->R):Parser<I,R>{
    return prs.mapR(
      function(r){
        return r.map(
          function(o){
            return o.map(fn);
          }
        );
      }
    );
  }
}