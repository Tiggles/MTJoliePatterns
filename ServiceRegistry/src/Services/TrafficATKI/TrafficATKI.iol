type DateRequest:string {
    .before?:bool
    .isTimestamp?:bool
}

type DateRange:void {
    .dateStart?:string
    .dateEnd?:string
}

type DateDataResponse:void {
    .row*:void {
        .datetime:string
        .messGroup:string
        .display:string
        .gap:string
        .length:string
        .class:string
        .wrong_dir:string
        .lane:string
        .speed:string
        .flash:string
        .stationID:string
    }
}

type MessGroupDataResponse:void {
    .row*:void {
		.lattitude:double
		.stationType:string
		.messGroup:string
		.display:string
		.longtitude:double
		.length:string
		.source:string
		.wrong_dir:string
		.speed:string
		.datetime:string
		.installDate:string
		.gap:string
		.name:string
		.class:string
		.expectedInterval:string
		.lane:string
		.status:string
		.direction:string
		.stationID:string
		.flash:string
    }
}


type StationDataResponse:void {
    .row*:void {
        .lattitude:double
        .stationType:string
        .messGroup:string
        .display:string
        .longtitude:double
        .length:string
        .source:string
        .wrong_dir:string
        .speed:string
        .datetime:string
        .installDate:string
        .gap:string
        .name:string
        .class:string
        .expectedInterval:string
        .lane:string
        .status:string
        .direction:string
        .stationID:string
        .flash:string
    }
}

type StationResponse:void {
    .row*:void {
        .installDate:string
        .lattitude:double
        .stationType:string
        .longtitude:double
        .name:string
        .source:string
        .expectedInterval:string
        .status:string
        .direction:string
        .stationID:string
    }
}

type MessGroups:void {
    .row*:void {
        .messGroup:string
    }
}


interface TrafficATKIInterface {
    RequestResponse:
        getMessGroups( DateRange )( MessGroups ),
        getStationDataCount( void ) ( long ),
        getStationCount( void ) ( long ),
        getByDate( DateRequest )( DateDataResponse ),
        getStations( void )( StationResponse ),
        getByMessGroup( string )( MessGroupDataResponse )
}

outputPort TrafficATKI {
    Interfaces: TrafficATKIInterface
}
