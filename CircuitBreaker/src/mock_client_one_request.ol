include "mock_service.iol"
include "console.iol"

main {
    println@Console( "init" )();
    req@ServicePort( { .content = "hello" } )( response )
}
