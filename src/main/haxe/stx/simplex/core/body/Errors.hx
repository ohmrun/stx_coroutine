package stx.simplex.core.body;

import tink.core.Error.Pos;

import haxe.PosInfos;

class Errors{
  static public function no_value_error(f:Fault){
    return f.because('Value expected and not found');
  }
  static public function driver_ended(f:Fault){
    return f.because('Driver ended');
  }
  static public function no_index_found(f:Fault,idx:Int){
    return f.because('Index $idx not found');
  }
  static public function timeout(f:Fault){
    return f.because("Timeout");
  }
  static public function input_exhaustion(f:Fault){
    return f.because("Input exhausted");
  }
  static public function error(f:Fault,msg:String){
    return f.because(msg);
  }
}