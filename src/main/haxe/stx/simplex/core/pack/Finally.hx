package stx.simplex.core.pack;

import stx.simplex.core.head.Data.Finally in FinallyT;

@:forward abstract Finally<R>(FinallyT<R>) from FinallyT<R> to FinallyT<R>{
    public function new(self){
        this = self;
    }
}