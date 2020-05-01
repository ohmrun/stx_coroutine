package stx.http;

import stx.coroutine.pack.Coroutine;

import haxe.Bytes;

import tink.http.Request;
import tink.http.Response;

typedef HttpProducer = Coroutine<Noise,Bytes,Error>;
typedef HttpDecoder  = Coroutine<Bytes,IncomingRequest,Error>;
typedef HttpHandler  = Coroutine<IncomingRequest,Bytes,Error>;
typedef HttpConsumer = Coroutine<Bytes,Noise,Error>;

typedef WebHandler   = Coroutine<Noise,Noise> -> Future<Maybe<Error>>;

//producer.pipe(decoder).pipe(handler).pipe(consumer);
