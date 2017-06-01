interface ParkingServiceWebInterface {
    RequestResponse:
        default( undefined )( undefined ),
        getCoordinates( undefined )( undefined ),
        ping( void )( void )
    OneWay:
        shutdown( void )
}
