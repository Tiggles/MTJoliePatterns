include "TrafficATKI.iol"
include "console.iol"
include "json_utils.iol"
include "string_utils.iol"
include "TrafficATKIPull.iol"

type StationDataRequest:void {
    .authenticationKey:string
    .data:void {
        .lane:string
        .display:string
        .flash:string
        .stationID:string
        .datetime:string
        .length:string
        .messGroup:string
        .gap:string
        .speed:string
        .class:string
        .wrong_dir:string
    }
}

type StationRequest:void {
    .authenticationKey:string
    .data:void {
        .status:string
        .direction:string
        .expectedInterval:string
        .longtitude:string
        .stationType:string
        .name:string
        .installDate:string
        .source:string
        .stationID:string
        .lattitude:string
    }
}

outputPort Traffic {
    Location: "socket://localhost:8020"
    Protocol: http
    Interfaces: TrafficATKIInterface, TrafficATKIServicePullInterface
}

main
{
    with ( req ) {
        .authenticationKey = "115d9d92-9c68-481d-9250-7c467a48c43a";
        with ( .data ) {
            .status = "1234";
            .direction = "asd";
            .expectedInterval = "1";
            .longtitude = "1.2";
            .stationType = "123";
            .name = "!";
            .installDate = "2017-02-27 18:41:25";
            .source = "123";
            .stationID = "123";
            .lattitude = "1.1"
        }
    };
    receiveStation@Traffic( req )( res );
    with ( req2 ) {
        .authenticationKey  = "115d9d92-9c68-481d-9250-7c467a48c43a";
        with ( .data ) {
            .lane = "1";
            .display = "0";
            .flash = "1";
            .stationID = "123";
            .datetime = "2017-02-27 18:41:25";
            .length = "5";
            .messGroup = "asd";
            .gap = "123";
            .speed = "60";
            .class = "2";
            .wrong_dir = "1"
        }
    };
    receiveStationData@Traffic( req2 )( res2 );
    println@Console( res )();
    println@Console( res2 )();
    getByDate@Traffic( "1" { .isTimestamp = true } )( result );
    valueToPrettyString@StringUtils( result )( result );
    println@Console( result )();
    getByStation@Traffic( "123" )( result );
    valueToPrettyString@StringUtils( result )( result );
    println@Console( result )();
    getStations@Traffic()( result);
    valueToPrettyString@StringUtils( result )( result );
    println@Console( result )();
    valueToPrettyString@StringUtils( re ) (rr );
    println@Console( rr )()
}
