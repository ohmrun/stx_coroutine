package stx.http;

import stx.coroutine.pack.Coroutine;

import haxe.Bytes;

import tink.http.Request;
import tink.http.Response;

typedef HttpProducer = Coroutine<Nada,Bytes,Error>;
typedef HttpDecoder  = Coroutine<Bytes,IncomingRequest,Error>;
typedef HttpHandler  = Coroutine<IncomingRequest,Bytes,Error>;
typedef HttpConsumer = Coroutine<Bytes,Nada,Error>;

typedef WebHandler   = Coroutine<Nada,Nada> -> Future<Maybe<Error>>;

//producer.pipe(decoder).pipe(handler).pipe(consumer);
