include "console.iol"
include "database.iol"
include "file.iol"
include "exec.iol"
include "string_utils.iol"
include "runtime.iol"

constants {
    databasename = "stats.db",
    debug = true
}

main {
    tryCreateDatabaseFile;
    initConnection;
    tryCreateTables
}

define initConnection
{
    with ( connectionInfo )
    {
        .username = .password = .host = "";
        .database = "stats.db";
        .driver = "sqlite";
        .checkConnection = 1
    };
    connect@Database( connectionInfo )( )
}

define tryCreateDatabaseFile
{
    exists@File( databasename )( exists );
    if (!exists)
    {
        commandExecutionRequest = "touch";
        with ( commandExecutionRequest ) {
            .args[0] = databasename;
            .waitFor = 1
        };
        exec@Exec( commandExecutionRequest )( execResult )
    }
}

define tryCreatePingTable
{
    pingTable =
    "CREATE TABLE IF NOT EXISTS " +
    "PingTable ( ServiceID bigint UNIQUE, LastPing DATETIME,  FOREIGN KEY(ServiceID) REFERENCES ServiceTable(ID));";
    updateRequest = pingTable;
    update@Database( updateRequest )( )
}

define tryCreateServiceTable
{
    println@Console( "Servicetable" )();
    serviceTable =
    "CREATE TABLE IF NOT EXISTS " +
    "ServiceTable (ID bigint PRIMARY KEY NOT NULL UNIQUE, " +
    "Name NVARCHAR(200), Location NVARCHAR(200), Protocol NVARCHAR(50), InterfaceFile NVARCHAR(5000), DocFile NVARCHAR(5000), OwnerID bigint NOT NULL, FOREIGN KEY(OwnerID) REFERENCES Owners(ID));";
    updateRequest = serviceTable;
    update@Database( updateRequest )( result )
}

define tryCreateOwnerTable
{
    println@Console( "Owners" )();
    ownerTable =
    "CREATE TABLE IF NOT EXISTS " +
    "Owners (ID bigint PRIMARY KEY NOT NULL UNIQUE, Name NVARCHAR(50), AuthenticationKey NVARCHAR(100) UNIQUE, Email NVARCHAR(100) UNIQUE);";
    updateRequest = ownerTable;
    update@Database( updateRequest )( result )
}

define tryCreateTestData
{
    println@Console( "testdata" )();
    testData =
    "INSERT OR REPLACE INTO ServiceTable " +
    "VALUES (0, 'Example', 'example.org', 'http', 'Not present', 'No docs associated with this service', 0)";
    updateRequest = testData;
    update@Database( updateRequest )( );
    query@Database( "SELECT * FROM ServiceTable ")( res );
    valueToPrettyString@StringUtils( res )( resp );
    println@Console( resp )();
    testData =
    "INSERT OR REPLACE INTO Owners " +
    "VALUES (0, 'Example.org', '0000', 'example@example.org')";
    updateRequest = testData;
    update@Database( updateRequest )( );
    testData =
    "INSERT OR REPLACE INTO Owners " +
    "VALUES (1, 'Jonas Malte Hinchely', 'e8185f0f-70cf-4113-b7da-29a6151847c5', 'jonas@hinchely.dk')";
    updateRequest = testData;
    update@Database( updateRequest )( );
    query@Database( "SELECT * FROM Owners ")( res );
    valueToPrettyString@StringUtils( res )( resp );
    println@Console( resp )()
}

define tryCreateTables
{
    tryCreatePingTable;
    tryCreateServiceTable;
    tryCreateOwnerTable;
    if ( debug )
    {
        tryCreateTestData
    }
}
