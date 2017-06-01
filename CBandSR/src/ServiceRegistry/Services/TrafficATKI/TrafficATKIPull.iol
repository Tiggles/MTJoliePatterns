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

interface TrafficATKIServicePullInterface {
    RequestResponse:
        receiveStation( StationRequest )( bool ),
        receiveStationData( StationDataRequest )( bool )
}
