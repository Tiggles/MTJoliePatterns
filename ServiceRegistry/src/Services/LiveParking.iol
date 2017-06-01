type LiveParkingList:void {
    .data[1,*]:void  {
        .name:string
        .idName:string
        .geometry:void {
            .type:string
            .coordinates[2, 2]:double
        }
        .maxCount:int
        .freeCount:int
    }
}

interface LiveParkingInterface {
    RequestResponse:
        getLiveParkingData( void )( LiveParkingList )
    OneWay:
        shutdown( void )
}

outputPort LiveParkingExternalService {
    Interfaces: LiveParkingInterface
}
