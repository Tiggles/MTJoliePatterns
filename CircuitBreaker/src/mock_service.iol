type MockRequest:void {
    .content:string
}

type MockResponse:void {
    .content:string
}

interface MockServiceIface {
    RequestResponse:
        req( MockRequest )( MockResponse ) throws CBFault
}

constants {
    CIRCUITBREAKER_LOCATION = "socket://localhost:8004",
    protocol = http
}

outputPort ServicePort {
    Location: CIRCUITBREAKER_LOCATION
    Protocol: protocol
    Interfaces: MockServiceIface
}
