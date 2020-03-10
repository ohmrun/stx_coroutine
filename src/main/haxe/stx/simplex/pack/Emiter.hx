package stx.simplex.pack;
 
import stx.simplex.pack.source.Generate;
import stx.simplex.head.Data.Emiter in EmiterT;
import stx.simplex.body.Emiters;
import stx.simplex.body.Sources;
import stx.simplex.core.body.Simplexs;

@:forward abstract Emiter<O>(EmiterT<O>) from EmiterT<O> to EmiterT<O>{
  @:from static public function fromThunk<O>(th:Thunk<O>):Emiter<O>{
    return Emiters.fromThunk(th);
  }
  @:from static public function fromNativeSimplex<O>(spx:stx.simplex.core.pack.Simplex<Noise,O,Noise>):Emiter<O>{
    return new Emiter(spx);
  }
  // @:from static public function fromSignal<T>(sig:Signal<T>):Emiter<T>{
  //   return Emiters.fromSignal(sig);
  // }
  @:to public function toSimplex():Simplex<Noise,O,Noise>{
    return this;
  }
  @:to public function toSource():Source<O,Noise>{
    return this;
  }
  @:to public function toSimplex():Simplex<Noise,O,Noise>{
    return this;
  }
  @:to public function unwrap():stx.simplex.core.head.Data.Simplex<Noise,O,Noise>{
    return this;
  }
  @:to public function toPipe():Pipe<Noise,O>{
    return this;
  }
  static public function unit<T>():Emiter<T>{
    return new Emiter(
      Wait(
        function(_:Control<Noise>){
          return Halt(Production(Noise));
        }
      )
    );
  }
  public function new(self:EmiterT<O>){
    this = self;
  }
  @:from static public function fromIterable<T>(iter:Iterable<T>):Emiter<T>{
    return Emiters.fromIterable(iter);
  }
  @:to public function toGenerate():Generate<O>{
    return new Generate(this);
  }
  /**
   *  Adds another value to the end of this Emiter *if* it terminates.
   *  If the original Emiter does not terminate, the value will never be available.
   *  @param o - 
   *  @return Emiter<O>
   */
  public function snoc(o:O):Emiter<O>{
    return Emiters.snoc(this,o);
  }
  public function cons(o:O):Emiter<O>{
    return Emiters.cons(this,o);
  }
  public function filter(fn:O->Bool):Emiter<O>{
    return Sources.filter(this,fn);
  }
  public function mapFilter<U>(fn:O->Option<U>):Emiter<U>{
    return Sources.mapFilter(this,fn);
  }
  public function map<U>(fn:O->U):Emiter<U>{
    return new Emiter(Simplexs.map(this,fn));
  }
  public function reduce<U>(fn:O->U->U,memo:U):Producer<U>{
    return Emiters.reduce(this,fn,memo);
  }
  public function first(){
    return Emiters.first(this);
  }
  public function last(){
    return Emiters.last(this);
  }
  public function flatMap<U>(fn:O->Emiter<U>):Emiter<U>{
    return Emiters.flatMap(this,fn);
  }
  public function sink(snk:Sink<O>):Effect{
    return Emiters.sink(this,snk);
  }
  public function search(fn:O->Bool){
    return Emiters.search(this,fn);
  }
  public function until(fn:O->Bool){
    return Emiters.until(this,fn);
  }
  public function toArray():Producer<Array<O>>{
    return Emiters.toArray(this);
  }
  public function tap(fn:Phase<Noise,O,Noise>->Void):Emiter<O>{
    return this.tap(fn);
  }
  public function merge(that:Emiter<O>):Emiter<O>{
    return Emiters.merge(this,that);
  }
  public function pipe<U>(p):Emiter<U>{
    return Emiters.pipe(this,p);
  }
}