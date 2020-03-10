package stx.process;

import stx.types.Thunk;

class Core{
  public function anything<I,O>(s:State<I,O>){
    return s.output(s.grammar.pure(
      s.input.item()
    ));
  }
}
enum Expr<I>{
  EBinop(bo:Binop,l:Expr<I>,r:Expr<I>);
  EUnop(un:Unop,e:Expr<I>);

  Empty;

  EAtom(t:Term<I>);
  EAction<O>(fn:I->O);
  EList(arr:Array<Expr<I>>);
}
enum Term<T>{
  TNone;
  TAtom(v:BTree<T>);
  TTerms(xs:Array<Term<T>>);
  TVar(vr:String);
}
enum Unop{
  Itr;
  Neg;
}
enum Binop{
  Seq;
  Alt;
}
typedef Parser<I,O> = State<I,O> -> Output;
enum BTree<T>{
  Empty;
  Node(el:Null<T>,left:Thunk<BTree<T>>,right:Thunk<BTree<T>>);
}
typedef Memo = Dynamic;

class State<I,O>{
  public var input    : BTree<I>;
  public var grammar  : Grammar<I,O>;
  public var memo     : Memo;
  public function new(){

  }
  public function clone(){

  }
}
class Output{

}
class Grammar<I,O> implements Dynamic{
  public function pure<I>(i:I):O{
    return cast i;
  }
}