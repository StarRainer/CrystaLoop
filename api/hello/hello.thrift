namespace go hello

// HelloRequest contains the query parameters accepted by the Hello endpoint.
struct HelloRequest {
    // Name is the person to greet.
    1: required string name (api.query="name")
}

// HelloResponse contains the JSON body returned by the Hello endpoint.
struct HelloResponse {
    // Message is the complete greeting, for example "Hello, World!".
    1: required string message (api.body="message")
}

// HelloService exposes the HelloWorld test endpoint.
service HelloService {
    // Hello returns a greeting for the supplied name.
    HelloResponse Hello(1: HelloRequest request) (
        api.get="/hello"
    )
}
