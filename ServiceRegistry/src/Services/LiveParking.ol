include "string_utils.iol"
include "console.iol"
include "time.iol"
include "Registering.iol"
include "file.iol"
include "LiveParking.iol"

execution{ concurrent }

outputPort LiveParkingHTTPS {
    Protocol: https {
                        .debug.showContent = .debug = false;
                        .method = "get";
                        .osc.download.alias = "/data/parkering/live.json";
                        .format = "json"
                    }
    Location: "socket://apps.odense.dk:443/"
    RequestResponse: download
}

embedded {
    Jolie: "Registering.ol" in RegisterService
}

constants {
    SECONDS_FIFTEEN_IN_MILLIS = 15000,
    LIVEPARKING_FILENAME = "LiveParking.ol",
    LIVEPARKING_INCLUDE_FILENAME = "LiveParking.iol",
    LIVEPARKING_NAME = "LiveParkingData",
    LIVEPARKING_LOCATION_LOCAL = "socket://localhost:8005",
    LIVEPARKING_LOCATION = "localhost:8005",
    LIVEPARKING_PROTOCOL = http,
    LIVEPARKING_PROTOCOL_STRING = "http",
    authenticationKey = "e8185f0f-70cf-4113-b7da-29a6151847c5",
    DEBUG = true
}

inputPort LiveParking {
    Location: LIVEPARKING_LOCATION_LOCAL
    Protocol: LIVEPARKING_PROTOCOL
    Interfaces: LiveParkingInterface
}

init
{
    global.lastDataRetrieval = 0L;
    generateAndGetJolieDocs@RegisterService( LIVEPARKING_FILENAME ) ( docFileLocation );
    readFile@File( { .filename = docFileLocation } )( docFileContent );
    readFile@File( { .filename = LIVEPARKING_INCLUDE_FILENAME } )( interfaceFile );

    with ( registerRequest ) {
        .serviceName = LIVEPARKING_NAME;
        .interfacefile = interfaceFile;
        .docFile = docFileContent;
        .authenticationKey = authenticationKey;
        .binding << {
            .location = LIVEPARKING_LOCATION,
            .protocol = LIVEPARKING_PROTOCOL_STRING
        }
    };

    registerService@RegisterService( registerRequest )( success )
}

main
{
    [ getLiveParkingData( )( response ) {
        getCurrentTimeMillis@Time( )( currentTime );
        if ( currentTime > global.lastDataRetrieval + SECONDS_FIFTEEN_IN_MILLIS ||  is_defined( global.parking_cache.data ) == false )
        {
            download@LiveParkingHTTPS( )( liveData );
            prettifyParkingData;
            global.parking_cache.data << formattedData;
            response.data << formattedData;
            global.lastDataRetrieval = currentTime
        } else {
            response.data << global.parking_cache.data
        }
    } ]
    [ shutdown( ) ] {
        if ( DEBUG )
            exit
    }
}

define prettifyParkingData
{
    i = 0;
    foreach ( key : liveData ) {
        if ( is_defined( liveData.( key ).name ) ) {
            with ( formattedData[i] ) {
                .name = liveData.( key ).name;
                .idName = liveData.( key ).idName;
                with ( .geometry ) {
                    .type = "Point";
                    .coordinates[0] = liveData.( key ).geometry.coordinates[0];
                    .coordinates[1] = liveData.( key ).geometry.coordinates[1]
                };
                .maxCount = liveData.( key ).maxCount;
                .freeCount = liveData.( key ).freeCount
            };
            i++
        }
    }
}
