include "CircuitBreakerConfig.iol"

interface CBIfaceExt {
    RequestResponse:
    OneWay:
        resetTO( void ),
        callTO( void ),
        closeTO( void )
}

outputPort CircuitBreaker {
    Location: CIRCUITBREAKER_LOCATION
    Protocol: CIRCUITBREAKER_PROTOCOL
    Interfaces: CBIfaceExt
}
