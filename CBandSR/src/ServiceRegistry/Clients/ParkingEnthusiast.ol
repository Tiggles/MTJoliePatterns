include "../Service_Registry.iol"
include "console.iol"
include "../Services/ParkingService.iol" // ASSUMED DOWNLOADET FROM REGISTRY
include "string_utils.iol"

main
{
    queryServices@ServiceRegistry( "ParkingService" )( result );
    ExternalService.location = "socket://" + result.row.Location;
    ExternalService.protocol = result.row.Protocol;
    get_info@ParkingExternalService( )( result );
    valueToPrettyString@StringUtils( result )( result );
    println@Console( result )();
    shutdown@ParkingExternalService( )
}
