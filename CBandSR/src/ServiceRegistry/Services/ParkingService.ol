include "console.iol"
include "CKAN/CKAN_Server.iol"
include "Other/GenericHTTP.iol"
include "string_utils.iol"
include "file.iol"
include "time.iol"
include "ParkingService.iol"
include "Registering.iol"

embedded {
    Jolie: "Registering.ol" in RegisterService
}

constants
{
    PARKING_SERVICE_LOCATION_LOCAL = "socket://localhost:8666",
    PARKING_SERVICE_LOCATION = "localhost:8665", // CircuitBreaker address
    PARKING_SERVICE_PROTOCOL_STRING = "sodep",
    PARKING_SERVICE_PROTOCOL = sodep,
    PARKING_SERVICE_FILENAME = "ParkingService.ol",
    PARKING_SERVICE_INCLUDE_FILENAME = "ParkingService.iol",
    PARKING_SERVICE_NAME = "ParkingService",
    authenticationKey = "e8185f0f-70cf-4113-b7da-29a6151847c5",
    DEBUG = true
}


execution { concurrent }


inputPort ParkingServiceInput {
  Location: PARKING_SERVICE_LOCATION_LOCAL
  Protocol: PARKING_SERVICE_PROTOCOL
  Interfaces: ParkingServiceInterface
}


init
{
    generateAndGetJolieDocs@RegisterService( PARKING_SERVICE_FILENAME ) ( docFileLocation );
    readFile@File( { .filename = docFileLocation } )( docFileContent );
    readFile@File( { .filename = PARKING_SERVICE_INCLUDE_FILENAME } )( interfaceFile );

    with ( registerRequest ) {
        .serviceName = PARKING_SERVICE_NAME;
        .interfacefile = interfaceFile;
        .docFile = docFileContent;
        .authenticationKey = authenticationKey;
        .binding << {
            .location = PARKING_SERVICE_LOCATION,
            .protocol = PARKING_SERVICE_PROTOCOL_STRING
        }
    };
    registerService@RegisterService( registerRequest )( success )
}

main
{
    [ get_info( )( response ) {
        getParkingData
    }]
    [ shutdown ( ) ] {
        if ( DEBUG ) {
            deregisterService@RegisterService( )( success );
            println@Console( "Shutdown: " + success )();
            if ( success == false ) {
                println@Console( "Removing service failed ")()
            } else {
                exit
            }
        }
    }
}


define getParkingData
{
    GenericHTTP.location = "socket://portal.opendata.dk:80/dataset/e5e26cac-e3d0-4a8b-95f4-830f3bab8cef/resource/ab561693-0d07-4ef5-a753-1ce4b3d430d8/download/parkering.json";
    download@GenericHTTP( )( response )
}

define getHandicapParkingData
{
    throw( NOTIMPLEMENTEDERROR )
}
