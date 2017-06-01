include "FakeWeatherService.iol"
include "string_utils.iol"
include "Registering.iol"
include "console.iol"
include "file.iol"

constants {
    FWS_LOCATION_LOCAL = "socket://localhost:8002",
    FWS_LOCATION = "localhost:8002",
    FWS_PROTOCOL = sodep,
    FWS_PROTOCOL_STRING = "sodep",
    authenticationKey = "e8185f0f-70cf-4113-b7da-29a6151847c5"
}

embedded {
    Jolie: "Registering.ol" in RegisterService
}

execution { concurrent }

inputPort FakeWeather {
    Location: FWS_LOCATION_LOCAL
    Protocol: FWS_PROTOCOL
    Interfaces: FakeWeatherInterface
}

init
{
    generateAndGetJolieDocs@RegisterService( "FakeWeatherService.ol" )( docFileLocation );
    readFile@File( { .filename = docFileLocation } )( docFileContent );
    readFile@File( { .filename = "FakeWeatherService.iol" } )( interfaceFile );
    with ( registerRequest ) {
        .serviceName = "FakeWeatherService";
        .interfacefile = interfaceFile;
        .docFile = docFileContent;
        .authenticationKey = authenticationKey;
        .binding << {
            .location = FWS_LOCATION,
            .protocol = FWS_PROTOCOL_STRING
        }
    };
    registerService@RegisterService( registerRequest )( success )
}

main
{
    [ getDayWeather( request )( response ) {
        toLowerCase@StringUtils( request.country )( country );
        if ( country == "england" ) {
            if ( request.zipcode == "EC2R 6AB") {
                response.degrees[0] = 10;
                response.weatherType[0] = "rain"
            }
        } else if ( country == "denmark" ) {
            if ( request.zipcode == "5000" ) {
                response.degrees[0] = 2;
                response.weatherType[0] = "blizzard"
            } else if ( request.zipcode == "1955" ) {
                response.degrees[0] = 24;
                response.weatherType[0] = "sunny"
            }
        }
    } ]

    [ getHourWeather( request )( response ) {
        toLowerCase@StringUtils( request.country )( country );
        if ( country == "england" ) {
            if ( request.zipcode == "EC2R 6AB") {
                response.degrees[0] = 10;
                response.weatherType[0] = "rain"
            }
        } else if ( country == "denmark" ) {
            if ( request.zipcode == "5000" ) {
                response.degrees[0] = 2;
                response.weatherType[0] = "blizzard"
            } else if ( request.zipcode == "1955" ) {
                response.degrees[0] = 24;
                response.weatherType[0] = "sunny"
            }
        }
    }]

    [ shutdown() ] {
        deregisterService@RegisterService( )( success );
        println@Console( "Shutdown: " + success )();
        if ( success == false ) {
            println@Console( "Removing service failed ")()
        } else {
            exit
        }
    }
}
