package stx.simplex.pack;

typedef TweenT = {min:Float,max:Float}->Pipe<Float,Float>;

abstract Tween(TweenT) from TweenT to TweenT{
    public function new(self){
        this = self;
    }
}