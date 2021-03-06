include "database.iol"
include "console.iol"
include "ServiceRegistry.iol"
include "string_utils.iol"
include "math.iol"
include "time.iol"

execution{ concurrent }


constants {
    PER_SERVICE_ROUND_ROBIN = 1,
    RANDOM = 2,
    STATUS_OK = 0,
    STATUS_FAILED = -1,
    STATUS_REREGISTER = 2,
    THIRTY_MINUTES = 1800000,
    DEBUG = true
}

inputPort InputDBPort {
    Location: "socket://localhost:8003"
    Protocol: sodep
    Interfaces: RegistryDBInterface
}

inputPort localPort {
    Location: "local"
    Interfaces: DeregisterInterface
}

define initConnection
{
    with (connectionInfo) {
        .username = .password = .host = "";
        .database = "stats.db";
        .driver = "sqlite";
        .checkConnection = 1
    };
    connect@Database( connectionInfo )( )
}

define getNextIDForOwner
{
    query@Database( "SELECT MAX(ID) as ID FROM Owners" )( res );
    nextID = res.row.ID + 1
}

define getNextIDForRegistering
{
    query@Database( "SELECT MAX(ID) as ID FROM ServiceTable" )( res );
    nextID = res.row.ID + 1
}

init
{
    initConnection;
    INDEXSELECTIONMODE = 1;
    scheduleTimeout@Time( THIRTY_MINUTES { .operation = "deregisterThread" } )( )
}

main
{
    [ register( request )( serviceID ) {
        scope( registerScope )
        {
            install( SQLException => serviceID = -1; println@Console( "Failure" )() );
            validateAuthentication;
            exists = false;
            checkIfServiceExists;
            if (exists == false) {
                getNextIDForRegistering;
                with ( request )
                {
                    update@Database("INSERT INTO ServiceTable VALUES (" + nextID + ", '" + .serviceName + "', '" + .binding.location + "', '" + .binding.protocol + "', '" + .interfacefile + "', '" + .docFile + "', " + OwnerID + ");" )();
                    update@Database("INSERT INTO PingTable VALUES (" + nextID + ", datetime('now'));")()
                };
                serviceID = nextID;
                global.total_services++
            }
        }
    }]
    [ deregister( request )( success ) {
        install( default => success = false );
        scope( deregisterScope )
        {
            validateAuthentication;
            update = "DELETE FROM ServiceTable WHERE id = " + request.id + " AND ownerID = " + OwnerID;
            update@Database( update )();
            success = true;
            global.total_services--
        }
    }]
    [ queryServices( queryRequest )( queryResponse ) {
        query = "SELECT st.Name, st.Location, st.Protocol FROM ServiceTable st WHERE st.Name = :queryRequest;";
        query.queryRequest = queryRequest;
        scope( queryScope )
        {
            install ( SQLException => queryResponse = "" );
            query@Database( query )( queryResult );
            serviceCount = #queryResult.row;
            getIndexValue;
            queryResponse.Location = queryResult.row[indexValue].Location;
            queryResponse.Protocol = queryResult.row[indexValue].Protocol
        }
    }]
    [ searchServices( queryRequest )( queryResponse ) {
        query = "SELECT st.Name, st.Location, st.Protocol, o.Name as OwnerName, (st.interfacefile is not null and st.interfacefile != '') as hasInterfaceFile, (st.docFile is not null and st.docFile != '') as hasDocFile  FROM ServiceTable st INNER JOIN Owners o ON o.ID = st.OwnerID WHERE st.Name like '%' || :queryRequest || '%' ";
        query.queryRequest = queryRequest;
        scope( queryScope )
        {
            install ( SQLException => queryResponse = "" );
            query@Database( query )( queryResponse )
        }
    }]
    [ getServiceInterface( queryRequest )( queryResponse ) {
        query = "SELECT st.InterfaceFile FROM ServiceTable st WHERE st.Name = '" + queryRequest + "'";
        query@Database( query )( response );
        queryResponse = response.row.InterfaceFile
    }]
    [ getServiceDocFile( queryRequest )( queryResponse) {
        query = "SELECT st.DocFile FROM ServiceTable st WHERE st.Name = '" + queryRequest + "'";
        query@Database( query )( response );
        queryResponse = response.row.DocFile
    }]
    [ ping( serviceID )( statusCode ) {
        query = "SELECT st.ID FROM ServiceTable st WHERE st.ID = " + serviceID + ";";
        query@Database( query )( queryResult );
        valueToPrettyString@StringUtils( queryResult )( res );
        if ( #queryResult.row > 0 ) {
            update = "INSERT OR REPLACE INTO PingTable VALUES (" + serviceID + ", datetime('now'));";
            update@Database( update )();
            statusCode = STATUS_OK
        } else {
            statusCode = STATUS_REREGISTER
        }

    }]
    [ getNewAuthenticationKey( request )( response ) {
        exists = false;
        checkIfOwnerExists;
        emailRegex = ".*@.*\\..*"; // Anything, @, Anything, ., Anything
        if ( exists == false ) {
            match@StringUtils( request.email { .regex = emailRegex })( match );
            if ( request.name != "" && match == 1 ) {
                getRandomUUID@StringUtils()( response );
                getNextIDForOwner;
                authenticationUpdate = "INSERT INTO Owners " +
                "VALUES (" + nextID + ", '" + request.name + "', '" + response + "', '" + request.email + "');";
                update@Database( authenticationUpdate )()
            } else {
                response = "Ugyldig e-mail eller navn er ikke udfyldt"
            }
        }
    }]
    [ deregisterThread() ] {
        deregisterThread
    }
    [ shutdown() ] {
        if ( debug )
            exit
    }
}

define compareServiceOwnerWithRegistrar
{
    query = "SELECT o.ID FROM Owners o WHERE o.AuthenticationKey = '" + request.authenticationKey + "'";
    query@Database( query )( ownerQueryResult );
    if ( ownerQueryResult.row.ID != queryResult.row.OwnerID )
    {
        serviceID = -1
    } else {
        correctOwner = true
    }
}

define checkIfOwnerExists
{
    query = "SELECT o.ID " +
            "FROM Owners o " +
            "WHERE o.Name = '" + request.name + "' AND o.email = '" + request.email + "';";
    query.name = request.name;
    query.email = request.email;
    query@Database( query )( res );
    if ( is_defined( res.row.ID ))
    {
        exists = true;
        response = ""
    }
}

define updateProtocolDocumentationAndIncludeFile
{
    with( request ){
        update =
        "UPDATE ServiceTable
        SET Protocol = '" + .binding.protocol + "', DocFile = '" + .docFile + "', InterfaceFile = '" + .interfacefile + "'
        WHERE ID = " + serviceID + ";";
        update@Database( update )( )
    }
}

define checkIfServiceExists
{
    with( request ){
        query = "SELECT st.ID, st.OwnerID FROM ServiceTable st INNER JOIN Owners o ON o.ID = st.OwnerID WHERE st.Name = '" + .serviceName + "' AND st.Location = '" + .binding.location + "' AND o.AuthenticationKey = '" + .authenticationKey + "'";
        query@Database( query )( queryResult );
        if ( is_defined( queryResult.row.ID ) ) {
            correctOwner = false;
            compareServiceOwnerWithRegistrar; // Overwrites ID if not matching owner
            if ( correctOwner ) {
                serviceID = queryResult.row.ID;
                updateProtocolDocumentationAndIncludeFile
            };
            exists = true
        }
    }
}

define getIndexValue
{
    if ( INDEXSELECTIONMODE == PER_SERVICE_ROUND_ROBIN ) {
        if ( is_defined( global.services.(queryRequest) ) == false) {
            global.services.(queryRequest) = 0
        };
        indexValue = global.services.(queryRequest);
        indexValue = indexValue++ % serviceCount;
        global.services.(queryRequest) = indexValue
    } else if ( INDEXSELECTIONMODE == RANDOM ) {
        random@Math()( randVal );
        indexValue = int((randVal * serviceCount) % serviceCount)
    }
}

define validateAuthentication
{
    query = "SELECT o.ID " +
    "FROM Owners o " +
    "WHERE o.AuthenticationKey = '" + request.authenticationKey + "';";
    query@Database( query )( queryRes );
    if ( is_defined( queryRes.row.ID ) == false ) {
        throw( NotExistingUser )
    } else {
        OwnerID = queryRes.row.ID
    }
}

define deregisterThread
{
    query = "SELECT ServiceID FROM PingTable WHERE LastPing < DATETIME('now', '-30 minutes'); ";
    query@Database( query )( queryResult );
    update = "DELETE FROM PingTable WHERE LastPing < DATETIME('now')";
    update@Database( update )();
    for (i = 0, is_defined( queryResult.row[i] ), i++) {
        update = "DELETE FROM ServiceTable WHERE id = " + queryResult.row[i].ServiceID;
        update@Database( update )()
    };
    query@Database( query )( queryResult );
    scheduleTimeout@Time( THIRTY_MINUTES { .operation = "deregisterThread" } )( )

}
