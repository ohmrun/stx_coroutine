package stx.simplex.body;

class Sinks{
    static public function handler<O>(fn:O->Void):Sink<O>{
        return Wait(
            function recurse (ctl:Control<O>):Sink<O>{
                return ctl.lift(
                    (o) -> {
                        fn(o);         
                        return Wait(recurse);
                    }
                );
            }
        );
    }
}