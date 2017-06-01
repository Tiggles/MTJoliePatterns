include "console.iol"
include "../ServiceRegistryLayer.iol"
include "Registering.iol"
include "exec.iol"
include "string_utils.iol"
include "time.iol"

constants {
    THIRTY_SECONDS = 30000,
    FIVE_MINUTES = 300000,
    STATUS_OK = 0,
    STATUS_FAILED = -1,
    STATUS_REREGISTER = 2,
    MAX_FAILURE_COUNT = 3,
    ALLOW_PING_STOP = true
}

inputPort localInput {
    Location: "local"
    Interfaces: RegisteringIFace
}

init
{
    global.serviceID = -1
}

execution { concurrent }

main
{
    [ registerService( registerRequest )( success ) {
        success = false;
        global.registerRequest << registerRequest;
        registerService@ServiceRegistry( registerRequest )( global.serviceID );
        scheduleTimeout@Time( 0 { .operation = "ping" } )( );
        println@Console( global.serviceID + " assigned as serviceID" )();
        if ( global.serviceID != STATUS_FAILED ) {
            success = true
        } else {
            throw( RegistryFailureFault )
        }
    } ]

    [ deregisterService ( )( success ) {
        success = false;
        if ( global.serviceID != -1 ) {
            deregisterService@ServiceRegistry( { .id = global.serviceID, .authenticationString = global.authenticationKey } )( success )
        }
    } ]
    [ generateAndGetJolieDocs( filenameRequest )( filenameResponse ) {
        // Not pretty solution, possible issues if filename contains whitespace?
        exec@Exec( "joliedoc" { .args[0] = filenameRequest, .waitFor = 1, .stdOutConsoleEnable = false } )( res );
        split@StringUtils( res { .regex = " " } )( splitResult );
        fileName = splitResult.result[2];
        length@StringUtils( fileName )( length );
        substring@StringUtils( fileName { .end = length - 1, .begin = 0 })( filenameResponse )
    }]
    [ getServiceID( )( global.serviceID )]
    [ ping( ) ] {
        ping
    }
}

define ping
{
    scope( pingScope )
    {
        install( IOException => status_code = STATUS_FAILED );
        ping@ServiceRegistry( global.serviceID )( status_code );
        if ( STATUS_REREGISTER == status_code ) {
                registerService@ServiceRegistry( global.registerRequest )( global.serviceID )
        };
        global.failureCount = 0
    };
    if ( STATUS_FAILED == status_code && ALLOW_PING_STOP ) {
        global.failureCount++;
        if ( global.failureCount > MAX_FAILURE_COUNT ) {
            println@Console( "FAILED" )();
            throw( RegistryFailureFault )
        }
    };
    scheduleTimeout@Time( THIRTY_SECONDS { .operation = "ping" } )( )
}
