package stx.process;


import fig.RefMaybeVal;
using stx.Arrays;
import stx.Equal;

import stx.Tuples.*;

using scuts.core.Options;
using scuts.core.Maps;
using scuts.core.Iterators;
import Map;
import tink.core.Error;
import stx.Tuple2;
import stx.types.Process;
import stx.Tables;
import stx.types.Table;

enum MapInput<K,V>{
  Set(k:K,v:V);
  Get(k:K);
  Dir;
  All;
}
typedef MapOutput<K,V> = Array<

enum Get<K,V>{
  At(k:K);
  Dir;
}
enum Set<K,V>{
  Rec(op:Get<K,V>);
  Del(v:V);
  Rem(k:K);
  Add(v:V);
  Put(v:V);
}
class Map{
  @noUsing static public function get<K,V>(map:IMap<K,V>):Process<Get<K,V>,Array<Tuple2<K,V>>>{
    return Wait(
      function rec(op:Get<K,V>){
        return switch (op) {
          case At(k)           :
            if(map.exists(k)){
              Emit([new Tuple2(k,map.get(k))],Wait(rec));
            }else{
              Halt(new Error(501,std.Std.string(k)));
            }
          case Dir              : Emit(stx.Maps.kvs(map).toArray(),Wait(rec));
        };
      }
    );
  }
  @noUsing static public function set<K,V>(map:std.Map<K,V>):Process<Set<K,V>,Array<Tuple2<K,Null<V>>>>{
    return Wait(
      function rec(op:Set<K,V>){
        return switch (op) {
          case Rec(At(k)) :
            if(map.exists(k)){
              Emit([new Tuple2(k,map.get(k))],Wait(rec));
            }else{
              Halt(new Error(501,std.Std.string(k)));
            }
          case Rec(Dir)         : Emit(map.toArray().map(Tuple2.fromTup2),Wait(rec));
          case Del(v)           :
            var val = map.toArray().map(Tuple2.fromTup2).search(
              function(tp){
                return Equal.getEqualFor(snd(tp))(snd(tp),v);
              }
            ).release();
            var key = fst(val);
            map.remove(key);
            //return Wait(rec);
            null;
          case Rem(k)           :
            map.remove(k);
            Wait(rec);
          case Add(v)           : Halt(new Error(501,"Hash Function not Defined"));
          case Put(v)           : Halt(new Error(501,"Hash Function not Defined"));
        }
      }
    );
  }
  @:noUsing static public function withPure<K,V>(prc:Process<Set<K,V>,Array<Tuple2<K,Null<V>>>>,pure:K->V){
    return prc.flatMap(
      function(x){
        return switch (x) {
          case Add(v)           :
          case Put(v)           : Halt(new Error(501,"Hash Function not Defined"));
        }
      }
    );
  }
}
