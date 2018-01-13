package stx.simplex.body;

import haxe.PosInfos;

class Errors{
    static public function no_value_error(?pos:PosInfos){
        return new stx.Error(500,'Value expected and not Found',pos);
    }
}