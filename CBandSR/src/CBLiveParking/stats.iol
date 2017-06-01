interface IfaceStats {
    OneWay:
        success( void ),
        timeout( void ),
        reset( void ),
        failure( void ),
        outputStatsToDB( void ),
        nextRollingWindow( void )
    RequestResponse:
        checkRate( void )( bool ),
        shouldTrip( void )( bool ),
        getStability( void )( bool )
}

// Use if stats is not embedded
/*
outputPort Stats {
    Location: "socket://localhost:8080"
    Protocol: sodep
    Interfaces: IfaceStats
}*/
