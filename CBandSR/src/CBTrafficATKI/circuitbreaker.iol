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
    Protocol: http /* { .compression = false; /* TO COMBAT BREACH */ /*.keyStoreFormat = "PKCS12"; .ssl.keyStore = "../opendata_sdu_dk.p12"; .ssl.keyStorePassword = "1qa2ws" } */
    Interfaces: CBIfaceExt
}
