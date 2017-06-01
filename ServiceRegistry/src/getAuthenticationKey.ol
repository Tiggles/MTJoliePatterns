include "ServiceRegistryLayer.iol"
include "console.iol"

main
{
    getNewAuthenticationKey@ServiceRegistry( { .name = "Jonas Malte Hinchely", .email = "jonas@hinchely.dk"  })( authKey );
    println@Console( authKey )()
}
