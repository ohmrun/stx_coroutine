package stx.simplex.pack;

import haxe.ds.Option;

using stx.Pointwise;

import stx.Error;

import stx.simplex.core.Data;

using stx.simplex.pack.Util;

import stx.simplex.core.Data.Process in ProcessT;

@:forward abstract Process<I,O>(ProcessT<I,O>) from ProcessT<I,O> to ProcessT<I,O>{
  public function new(self){
    this = self;
  }
  public function flatMap<O1>(fn:O->Process<I,O1>):Process<I,O1>{
    return Processes.flatMap(this,fn);
  }  
}