package stx.fail;

enum abstract CoroutineFailureNote(String) from String to String{
  var E_Coroutine_Note_HangingInput;
  var E_Coroutine_Note_UnexpectedStop;
  var E_Coroutine_Note_Requirement_Not_Encountered;
  var E_Coroutine_Note_UnexpectedWait;
} 