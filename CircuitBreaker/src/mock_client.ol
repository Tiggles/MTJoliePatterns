include "mock_service.iol"
include "console.iol"

main {
    spawn ( i over 3000) {
        req@ServicePort( { .content = "hello" } )( response )
    }
}
