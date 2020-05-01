package stx.coroutine.pack.Coroutine.parser;

import stx.coroutine.pack.Coroutine.parser.data.Seq as SeqT;

@:forward abstract Seq<T>(SeqT<T>) from SeqT<T> to SeqT<T>{
  public function new(self){
    this = self;
  }
  @:from static public function fromArray<T>(array:Array<T>):Seq<T>{
    var idx = 0;
    return new Seq({
      peek: function():Null<T>{
        return array[idx];
      },
      next: function(){
        idx = idx+1;
      },
      done: function(){
        return idx == array.length;
      }
    });
  }
  static public function pure<T>(v:T):Seq<T>{
    var is_done = false;
    return new Seq({
      peek: function():Null<T>{
        return v;
      },
      next: function(){
        is_done = true;
      },
      done: function(){
        return is_done;
      }
    });
  }
  static public function zero<T>():Seq<T>{
    return {
      peek: function(){
        return null;
      },
      next: function(){

      },
      done: function(){
        return true;
      }
    }
  }
  public function map<U>(fn:Null<T>->Null<U>):Seq<U>{
    return new Seq({
      peek: function(){
        return fn(this.peek());
      },
      next: this.next,
      done: this.done
    });
  }
  @:to public function toIterator(){
    return {
      next : function(){
        var out = this.peek();
        this.next();
        return out;
      },
      hasNext: function(){
        return !this.done();
      }
    }
  }
  public function reduce<U,Z>(fn:T->Z->Z,init:Z):Z{
    var out = init;
    while(!this.done()){
      out = fn(this.peek(),out);
      this.next();
    } 
    return out;
  }
}