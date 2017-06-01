include "../ServiceRegistry/Services/TrafficATKI/TrafficATKI.iol"
include "../ServiceRegistry/Services/TrafficATKI/TrafficATKIPull.iol"

constants {
    CIRCUITBREAKER_LOCATION = "socket://localhost:8020", // CHANGE DEPENDING ON CB LOCATION
    SERVICE_LOCATION = "socket://localhost:8021", // CHANGE DEPENDING ON SERVICE LOCATION
    SERVICE_INTERFACE = TrafficInterface
    // We use multiple interfaces, so it can't be used // SERVICE_INTERFACE = , // CHANGE DEPENDING ON SERVICE INTERFACE
}

// explicitly define mixed interface
interface TrafficInterface {
    RequestResponse:
        getMessGroups( DateRange )( MessGroups ),
        getStationDataCount( void ) ( long ),
        getStationCount( void ) ( long ),
        getByDate( DateRequest )( DateDataResponse ),
        getStations( void )( StationResponse ),
        getByMessGroup( string )( MessGroupDataResponse ),
        receiveStation( StationRequest )( bool ),
        receiveStationData( StationDataRequest )( bool )
}

outputPort Service {
    Location: SERVICE_LOCATION
    Protocol: http /* { .compression = false; /* TO COMBAT BREACH */ /*.keyStoreFormat = "PKCS12"; .ssl.keyStore = "../opendata_sdu_dk.p12"; .ssl.keyStorePassword = "1qa2ws" } */
    Interfaces: TrafficInterface // CHANGE DEPENDING ON SERVICE INTERFACE; IF OUTPUTPORT ADDS CHECKCONSTANTS, THIS CAN BE REPLACED
}
