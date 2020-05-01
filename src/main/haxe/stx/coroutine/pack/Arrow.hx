package stx.coroutine.pack;

typedef ArrowT<P,I,O,R> = P -> Coroutine<I,O,R,E>;

@:forward @:callable abstract Arrow<P,I,O,R,E>(ArrowT<P,I,O,R,E>) from ArrowT<P,I,O,R,E> to ArrowT<P,I,O,R,E>{
    public function new(self){
        this = self;
    }
    public function pipe<O2>(that:Arrow<P,O,O2,R>){
        return (p:P) -> {
            var l = this(p);
            var r = that(p);
            return l.pipe(r);
        }
    }
    public function then<R2>(that:Arrow<R,I,O,R2>){
        return (p:P) -> {
            var l = this(p);
            return l.flatMapR(that);
        }
    }
    //Arrow<Tuple2<P0,P1>,I,O,Tuple2<R0,R1>>
    /*
    static public function both<P,I1,O1,R1,P2,I2,O2,R>(self:Arrow<P,I1,O1,R>,that:Arrow<P,I2,O2,R>){
        return (p) -> {
            function recurse(l,r){
                return switch([l,r]){
                    default : null;
                }
            }
            var l = self(p);
            var r = that(p);
            
            return Wait(
                function(tp:Tuple2<I1,I2>){
                    var tl   = tp.fst();
                    var tr   = tp.snd();
                    var outl = l.provide(tl);
                    var outr = r.provide(tr);
                    return switch([outl,outr]{
                        case [Halt(l),_]            : Halt(l);
                        case [_,Halt(r)]            : Halt(r);
                        case [Wait(l),Wait(r)]      : 
                        default                     :  
                    })
                }
            );
        }
    }*/
    /*
    public function first(){
        
    }*/
}
//typedef BothT<P0,P1,I,O,R1,R2> = Arrow<Tuple2<P0,P1>,I,O,Tuple2<R1,R2>>;