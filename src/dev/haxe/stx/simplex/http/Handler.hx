package stx.http;

import tink.http.Request;
import tink.http.Response;

typedef HttpProducer            = Emiter<Bytes>;
typedef HttpDecoder             = Pipe<Bytes,IncomingRequest>;
typedef HttpRequestBuilder<T>   = Arrowlet<IncomingRequest,T>;
typedef HttpMiddleware<T>       = Arrowlet<T,T>;
typedef HttpHandler             = Pipe<T,Bytes>;
typedef HttpConsumer            = Sink<Bytes>;

