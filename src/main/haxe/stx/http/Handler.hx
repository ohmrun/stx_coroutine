package stx.http;

import stx.Simplex;

import haxe.Bytes;

import tink.http.Request;
import tink.http.Response;

typedef HttpProducer = Simplex<Noise,Bytes,Error>;
typedef HttpDecoder  = Simplex<Bytes,IncomingRequest,Error>;
typedef HttpHandler  = Simplex<IncomingRequest,Bytes,Error>;
typedef HttpConsumer = Simplex<Bytes,Noise,Error>;

typedef WebHandler   = Simplex<Noise,Noise> -> Future<Maybe<Error>>;

//producer.pipe(decoder).pipe(handler).pipe(consumer);
