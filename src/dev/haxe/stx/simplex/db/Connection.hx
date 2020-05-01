package stx.coroutine.pack.Coroutine.db;

import sys.db.Mysql;


import stx.coroutine.pack.core.Data.Coroutine;
import stx.coroutine.pack.core.Data.Control;
import stx.coroutine.pack.Coroutine.Control;
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

abstract Connection(Coroutine<SQLInput,ResultSet,Error>){
  public function new(connector:SQLOptions->sys.db.Connection){
    this = Wait(apply.bind(connector));
  }
  @:from static public function fromMySql(m:Class<Mysql>){
    return new Connection(Mysql.connect);
  }
  static function apply(connector:SQLOptions->sys.db.Connection,input:Control<SQLInput>):Coroutine<SQLInput,ResultSet,Error>{
    return input.lift(
      function(input){
        return switch(input){
          case SQLConnect(options) :
            var connection  = connector(options);
            Wait(
              function post_connect_handler(input:Control<SQLInput>){
                return Controls.lift(input,
                  function(input){
                    return switch(input){
                        case SQLRequest(input) :
                          var result = connection.request(input);
                          Emit(result,Wait(post_connect_handler));
                        case SQLExecute(input) :
                          connection.request(input);
                          Wait(post_connect_handler);
                        case SQLConnect(input) : apply(connector,Continue(SQLConnect(input)));//reconnect
                      }
                    }
                  );
                }
            );
          default: Halt(Error.withData(500,'Not Connected',SQLNotConnected));
        }   
      }
    );
  }
}