package stx.pump.io;

import stx.pump.data.Simplex;
using stx.Tuple;
import asys.io.process.Data;
import asys.io.process.Type;
import asys.io.process.Value;
import tink.core.Error;
using stx.async.Arrowlet;

import haxe.io.Input;
import stx.Simplex;

class Input{
  static public inline function pull(ip:haxe.io.Input,un:Type):Value{
    return tuple2(un,switch (un) {
      case I8      :
        PInt(ip.readInt8());
      case I16BE   :
        ip.bigEndian = true;
        PInt(ip.readInt16());
      case I16LE   :
        ip.bigEndian = false;
        PInt(ip.readInt16());
      case UI16BE  :
        ip.bigEndian = true;
        PInt(ip.readUInt16());
      case UI16LE  :
        ip.bigEndian = false;
        PInt(ip.readUInt16());

      case I24BE   :
        ip.bigEndian = true;
        PInt(ip.readInt24());
      case I24LE   :
        ip.bigEndian = false;
        PInt(ip.readInt24());
      case UI24BE  :
        ip.bigEndian = true;
        PInt(ip.readUInt24());
      case UI24LE  :
        ip.bigEndian = false;
        PInt(ip.readUInt24());

      case I32BE   :
        ip.bigEndian = true;
        PInt(ip.readInt32());
      case I32LE   :
        ip.bigEndian = false;
        PInt(ip.readInt32());
      case FBE     :
        ip.bigEndian = true;
        PFloat(ip.readFloat());
      case FLE     :
        ip.bigEndian = false;
        PFloat(ip.readFloat());
      case DBE     :
        ip.bigEndian = true;
        PFloat(ip.readDouble());
      case DLE     :
        ip.bigEndian = false;
        PFloat(ip.readDouble());
      case LINE    :
        PString(ip.readLine());
    });
  }
  static public function apply(ip:haxe.io.Input):stx.Simplex<Type,Value>{
    function producer(un:Type):stx.Simplex<Type,Value>{
      var o = null;
          o = try{
            Emit(pull(ip,un),Wait(producer));
          }catch(e:Error){
            Halt(e);
          }catch(d:Dynamic){
            Halt(Error.withData(500,'Error in Input',d));
          }
      return o;
    }
    return Wait(producer);
  }
}
