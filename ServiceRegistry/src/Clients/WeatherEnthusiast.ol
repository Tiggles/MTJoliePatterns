// IF USING SERVER
// include "DigitalOceanSR.iol"

include "../ServiceRegistryLayer.iol"
include "console.iol"
include "../Services/FakeWeatherService.iol"
include "ui/swing_ui.iol"

main
{
    queryServices@ServiceRegistry( "FakeWeatherService" )( result );
    println@Console( result.row.Location )();
    ExternalService.location = "socket://" + result.row.Location;
    ExternalService.protocol = result.row.Protocol;
    getDayWeather@WeatherExternalService( { .country = "denmark", .zipcode = "1955" } )( res );
    showMessageDialog@SwingUI("In the country of denmark, in the zipcode 1955, the number of degrees is " + res.degrees[0] + " and the weather is " + res.weatherType[0] )();
    shutdown@WeatherExternalService()
}
