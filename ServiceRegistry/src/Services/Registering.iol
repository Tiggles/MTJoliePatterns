include "../common/type_registering.iol"

interface RegisteringIFace {
    RequestResponse:
        registerService( RegisterRequest )( bool ),
        deregisterService( void )( bool ),
        generateAndGetJolieDocs( string )( string ),
        getServiceID( void )( long )
    OneWay:
        ping( void )
}

outputPort RegisterService {
    Location: "local"
    Interfaces: RegisteringIFace
}
