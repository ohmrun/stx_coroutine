package stx.pump.io;

import tink.CoreApi;

import asys.io.process.*;

class Output{
  static public inline function push(op:haxe.io.Output,value:Value):Surprise<Noise,Error>{
    var valAsInt    = null;
    var valAsString = null;
    var valAsFloat  = null;

    switch(value.data){
      case PString(str):
        valAsString = str;
      case PFloat(fl):
        valAsFloat  = fl;
      case PInt(int):
        valAsInt    = int;
    }
    switch(value.type){
      case I8      :
        op.writeInt8(valAsInt);
      case I16BE   :
        op.bigEndian = true;
        op.writeInt16(valAsInt);
      case I16LE   :
        op.bigEndian = false;
        op.writeInt16(valAsInt);
      case UI16BE  :
        op.bigEndian = true;
        op.writeUInt16(valAsInt);
      case UI16LE  :
        op.bigEndian = false;
        op.writeUInt16(valAsInt);
      case I24BE   :
        op.bigEndian = true;
        op.writeInt24(valAsInt);
      case I24LE   :
        op.bigEndian = false;
        op.writeInt24(valAsInt);
      case UI24BE  :
        op.bigEndian = true;
        op.writeUInt24(valAsInt);
      case UI24LE  :
        op.bigEndian = false;
        op.writeUInt24(valAsInt);
      case I32BE   :
        op.bigEndian = true;
        op.writeInt32(valAsInt);
      case I32LE   :
        op.bigEndian = false;
        op.writeInt32(valAsInt);
      case FBE     :
        op.bigEndian = true;
        op.writeFloat(valAsFloat);
      case FLE     :
        op.bigEndian = false;
        op.writeFloat(valAsFloat);
      case DBE     :
        op.bigEndian = true;
        op.writeDouble(valAsFloat);
      case DLE     :
        op.bigEndian = false;
        op.writeDouble(valAsFloat);
      case LINE    :
        op.writeString(valAsString);
    }
    return Future.sync(Success(Noise));
  }
}
