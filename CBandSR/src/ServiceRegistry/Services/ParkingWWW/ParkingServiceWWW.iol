interface ParkingServiceWebInterface {
    RequestResponse:
        default( undefined )( undefined ),
        getCoordinates( void )( undefined ),
        ping( void )( void )
    OneWay:
        shutdown( void )
}
