include "common/type_registering.iol"

constants
{
    SERVICE_REGISTRY_LOCATION = "socket://localhost:8001",
    SERVICE_REGISTRY_PROTOCOL = sodep
}

interface ServiceRegistryInterface {
    RequestResponse:
        registerService( RegisterRequest )( long ),
        deregisterService( DeregisterRequest )( bool ),
        queryServices( string )( undefined ),
        getServiceInterface( string )( string ),
        getServiceDocFile( string )( string ),
        searchServices( string )( undefined ),
        getNewAuthenticationKey( OwnerRequest )( string ),
        ping( long )( int )
}

outputPort ServiceRegistry {
    Location: SERVICE_REGISTRY_LOCATION
    Protocol: SERVICE_REGISTRY_PROTOCOL
    Interfaces: ServiceRegistryInterface
}
