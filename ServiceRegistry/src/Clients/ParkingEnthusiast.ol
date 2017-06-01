// IF USING SERVER
// include "DigitalOceanSR.iol"


include "../Service_Registry.iol"
include "console.iol"
include "../Services/ParkingService.iol" // ASSUMED DOWNLOADED FROM REGISTRY
include "string_utils.iol"

main
{
    queryServices@ServiceRegistry( "ParkingService" )( result );
    valueToPrettyString@StringUtils( result )( ressy );
    println@Console( ressy )();
    ExternalService.location = "socket://" + result.row.Location;
    ExternalService.protocol = result.row.Protocol

}
