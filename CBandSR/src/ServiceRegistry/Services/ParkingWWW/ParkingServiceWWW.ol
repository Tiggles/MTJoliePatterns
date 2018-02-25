include "console.iol"
include "../CKAN/CKAN_Server.iol"
include "../Other/GenericHTTP.iol"
include "string_utils.iol"
include "../../ServiceRegistryLayer.iol"
include "file.iol"
include "ParkingServiceWWW.iol"
include "../Registering.iol"
include "../ParkingService.iol"
include "../LiveParking.iol"
include "time.iol"
include "math.iol"

embedded {
    Jolie: "../Registering.ol" in RegisterService
}

constants
{
    PARKING_SERVICEWWW_LOCATION_LOCAL = "socket://localhost:8667",
    PARKING_SERVICEWWW_LOCATION = "localhost:8667",
    PARKING_SERVICEWWW_PROTOCOL_STRING = "http",
    PARKING_SERVICEWWW_PROTOCOL = http,
    PARKING_SERVICEWWW_FILENAME = "ParkingServiceWWW.ol",
    PARKING_SERVICEWWW_INCLUDE_FILENAME = "ParkingServiceWWW.iol",
    PARKING_SERVICEWWW_NAME = "ParkingServiceWWW",
    GOOGLE_MAPS_API_KEY = "AIzaSyA8nvjEvpW07Elo84YLXeVxcelnybsha7Y",
    MINUTE_IN_MILLIS = 60000,
    authenticationKey = "e8185f0f-70cf-4113-b7da-29a6151847c5",
    DEBUG = true
}


execution { concurrent }

inputPort WebsitePort {
    Location: PARKING_SERVICEWWW_LOCATION_LOCAL
    Protocol: http { .format -> format; .contentType -> mime; .default = "default"; .contentDisposition -> contentDisposition }
    Interfaces: ParkingServiceWebInterface
}

init
{
    with ( registerRequest ) {
        .serviceName = PARKING_SERVICEWWW_NAME;
        .interfacefile = "";
        .docFile = "";
        .authenticationKey = authenticationKey;
        .binding << {
            .location = PARKING_SERVICEWWW_LOCATION,
            .protocol = PARKING_SERVICEWWW_PROTOCOL_STRING
        }
    };
    registerService@RegisterService( registerRequest )( success );
    global.lastDataRetrieval = 0
}

main
{
    [ default( request )( response )
    {
        format = "html";
        contains@StringUtils( request.operation { .substring = ".." } )( reversePathTraversal );
        if (request.operation == "" || reversePathTraversal )
        {
            request.operation = "index.html"
        };
        exists = false;
        if ( reversePathTraversal == false ) {
            exists@File( request.operation )( exists )
        };

        if (!exists)
        {
            request.operation = "index.html"
        };
        readFile@File( { .filename = request.operation } )( response )
    }]
    [ getCoordinates( void )( response ) {
        getAndFormatParkingDataResponse
    }]
    [ shutdown ( void ) ] {
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

define addParkingSpotInfo
{
    slack = 0.0001;
    for (i = 0, i < #response.geometryPoints, i++ )
    {
        for ( j = 0, j < #liveData.data, j++ ) {
            x_1 = liveData.data[j].geometry.coordinates[0]; y_1 = liveData.data[j].geometry.coordinates[1];
            x_2 = response.geometryPoints[i].lng; y_2 = response.geometryPoints[i].lat;
            abs_x = x_1 - x_2; if ( abs_x < 0 ) abs_x = 0-abs_x; // Not in current Jolie build // fabs@Math( x_1 - x_2 )( abs_x );
            abs_y = y_1 - y_2; if ( abs_y < 0 ) abs_y = 0-abs_y; // Not in current Jolie build // fabs@Math( y_1 - y_2 )( abs_y );
            if ( abs_x < slack && abs_y < slack) {
                response.contentStrings[i] += "<b>Frie pladser: </b>" + liveData.data[j].freeCount + "<br>";
                response.contentStrings[i] += "<b>Samlet antal pladser: </b>" + liveData.data[j].maxCount + "<br>";
                response.contentStrings[i] += "<b>ASSUMED NAME: </b>" + liveData.data[j].name + "<br>";
                response.icon[i] = "https://developers.google.com/maps/documentation/javascript/examples/full/images/beachflag.png"
            }
        }
    }
}

define formatParkingDataResponse
{
    for (i = 0, i < #result.features, i++) {
        response.geometryPoints[i].lng = result.features[i].geometry.coordinates[0];
        response.geometryPoints[i].lat = result.features[i].geometry.coordinates[1];
        response.contentStrings[i] = "";
        foreach( prop : result.features[i].properties ) {
            response.contentStrings[i] += "<b>" + prop + ":</b> " + result.features[i].properties.(prop) + "</br>"
        }
    };
    addParkingSpotInfo;
    global.parkingCache << response
}

define getAndFormatParkingDataResponse
{
    getCurrentTimeMillis@Time()( time );
    if ( long(global.lastDataRetrieval + MINUTE_IN_MILLIS ) < time ) {
        queryServices@ServiceRegistry( "ParkingService" )( portResult );
        queryServices@ServiceRegistry( "LiveParkingData" )( livePortResult );
        if ( portResult == "" || livePortResult = "" ) {
            throw( ServiceRegistryFault )
        } else {

            ParkingExternalService.location = "socket://" + portResult.Location;
            ParkingExternalService.protocol = portResult.Protocol;

            LiveParkingExternalService.location = "socket://" + livePortResult.Location;
            LiveParkingExternalService.protocol = livePortResult.Protocol;

            scope( LiveParking )
            {
                install( default => println@Console( "No Live Parking endpoint found" )() );
                getLiveParkingData@LiveParkingExternalService()( liveData )
            };

            scope( Parking )
            {
                install( default => println@Console( "No parking endpoint found" )());
                get_info@ParkingExternalService()( result )
            };

            if ( #result.features != 0 ) {
                formatParkingDataResponse;
                global.lastDataRetrieval = time
            } else { // EITHER RETURNS CONTENTS OR CACHE
                response << global.parkingCache
            }
        }
    } else {
        response << global.parkingCache
    }
}
