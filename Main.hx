class Main{
  static function main(){
    final facade = stx.log.Facade.instance;
          facade.includes.push("stx/coroutine");
          facade.includes.push("stx/test");
          facade.includes.push('haxe/overrides');
    stx.coroutine.Test.main();
  }
}