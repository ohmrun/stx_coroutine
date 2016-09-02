package stx.simplex.db;

import sys.db.Mysql;

import stx.simplex.data.Simplex;
using tink.CoreApi;
import sys.db.ResultSet;

enum SQLFaults{
  SQLNotConnected;
}

enum SQLInput{
  SQLConnect(options:SQLOptions);
  SQLRequest(input:String);
  SQLExecute(input:String);//Some drivers will throw a wobbly if you call results on a request that returns no result.
}
typedef SQLOptions  = { user : String, pass : String, host : String, database: String, ?socket : Null<String>, ?port : Null<Int> };

abstract Connection(Simplex<SQLInput,ResultSet,Error>){
  public function new(connector:SQLOptions->sys.db.Connection){
    this = Wait(apply.bind(connector));
  }
  @:from static public function fromMySql(m:Class<Mysql>){
    return new Connection(Mysql.connect);
  }
  static function apply(connector:SQLOptions->sys.db.Connection,input:SQLInput):Simplex<SQLInput,ResultSet,Error>{
    return switch(input){
      case SQLConnect(options) :
        var connection  = connector(options);
        Wait(
          function post_connect_handler(input:SQLInput){
            return switch(input){
              case SQLRequest(input) :
                var result = connection.request(input);
                Emit(result,Wait(post_connect_handler));
              case SQLExecute(input) :
                connection.request(input);
                Wait(post_connect_handler);
              case SQLConnect(input) : apply(connector,SQLConnect(input));//reconnect
            }
          }
        );
      default: Halt(Error.withData(500,'Not Connected',SQLNotConnected));
    }
  }
