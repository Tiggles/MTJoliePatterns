include "../Registering.iol"
include "file.iol"
include "TrafficATKI.iol"
include "exec.iol"
include "database.iol"
include "console.iol"
include "string_utils.iol"
include "TrafficATKIPull.iol"
include "time.iol"

embedded {
    Jolie: "../Registering.ol" in RegisterService
}

constants
{
    TRAFFICATKI_SERVICE_LOCATION_LOCAL = "socket://localhost:8020",
    TRAFFICATKI_SERVICE_LOCATION = "localhost:8020",
    TRAFFICATKI_SERVICE_PROTOCOL_STRING = "http",
    //TRAFFICATKI_SERVICE_PROTOCOL = http,
    HARDCODED_VALUE = "115d9d92-9c68-481d-9250-7c467a48c43a",
    TRAFFICATKI_SERVICE_FILENAME = "TrafficATKI.ol",
    TRAFFICATKI_SERVICE_INCLUDE_FILENAME = "TrafficATKI.iol",
    TRAFFICATKI_SERVICE_NAME = "TrafficData ATKI Service",
    authenticationKey = "e8185f0f-70cf-4113-b7da-29a6151847c5"
}

execution { concurrent }

inputPort TrafficATKI {
    Location: TRAFFICATKI_SERVICE_LOCATION_LOCAL
    Protocol: http { .keepAlive = false }
    /* https { .compression = false; /* TO COMBAT BREACH */ /*.keyStoreFormat = "PKCS12"; .ssl.keyStore = "../../../opendata_sdu_dk.p12"; .ssl.keyStorePassword = "1qa2ws" } */
    Interfaces: TrafficATKIInterface, TrafficATKIServicePullInterface
}

init
{
    global.databaseName = "TrafficData.db";
    generateAndGetJolieDocs@RegisterService( TRAFFICATKI_SERVICE_FILENAME ) ( docFileLocation );
    readFile@File( { .filename = docFileLocation } )( docFileContent );
    readFile@File( { .filename = TRAFFICATKI_SERVICE_INCLUDE_FILENAME } )( interfaceFile );

    with ( registerRequest ) {
        .serviceName = TRAFFICATKI_SERVICE_NAME;
        .interfacefile = interfaceFile;
        .docFile = docFileContent;
        .authenticationKey = authenticationKey;
        .binding << {
            .location = TRAFFICATKI_SERVICE_LOCATION,
            .protocol = TRAFFICATKI_SERVICE_PROTOCOL_STRING
        }
    };

    registerService@RegisterService( registerRequest )( success );

    tryCreateDatabaseFile;
    initConnection;
    tryCreateDBTables

}

define tryCreateDatabaseFile
{
    exists@File( global.databaseName )( exists );
    if (!exists)
    {
        commandExecutionRequest = "touch";
        with ( commandExecutionRequest ) {
            .args[0] = global.databaseName;
            .waitFor = 1
        };
        exec@Exec( commandExecutionRequest )( execResult )
    }
}

main
{
    [ receiveStation( receiveRequest )( accepted ) {
        validateAuthenticationKey;
        if ( accepted ) { addStationToDB }
    } ]
    [ receiveStationData( receiveRequest )( accepted ) {
        validateAuthenticationKey;
        if ( accepted ) { addStationDataToDB }
    }]
    /* This will lead to memory issues
    [ getAllData( void )( data ) {
        query = "SELECT * FROM Station s INNER JOIN StationData sd ON sd.stationID = s.stationID;";
        query@Database( query )( data );
        println@Console( "GETTING ALL DATA" )();
        valueToPrettyString@StringUtils( data )( res );
        println@Console( res )()
    }]*/
    [ getMessGroups( dateRange )( messGroupList ) {
        if ( is_defined( dateRange.dateStart ) == false || is_defined( dateRange.dateEnd ) == false)
            query = "SELECT DISTINCT(messGroup) FROM StationData;"
        else {
            query = "SELECT DISTINCT(messGroup) FROM StationData WHERE datetime( datetime ) >= :dateStart AND datetime( datetime ) <= :dateEnd;";
            query.dateStart = dateRange.dateStart;
            query.dateEnd = dateRange.dateEnd
        };
        query@Database( query )( messGroupList )
    }]
    [ getByDate( date )( data ) {
        if ( date.isTimestamp ) getDateTime@Time( long(date) { .format= "YYYY-MM-DD HH:mm:ss" } )( date );
        query = "SELECT * FROM StationData WHERE datetime( datetime ) ";
        if ( date.before ) {
            query += "<= datetime( :date ) ORDER BY datetime ASC LIMIT 5000;"
        }
        else {
            query += ">= datetime( :date ) ORDER BY datetime ASC LIMIT 5000;"
        };
        query.date = date;
        query@Database( query )( data )
    }]
    [ getStationDataCount( void ) ( count ) {
        query@Database( "SELECT COUNT(*) AS StationDataCount FROM StationData;" )( result );
        count = result.row.StationDataCount
    }]
    [ getStationCount( void ) ( count ) {
        query@Database( "SELECT COUNT(*) AS StationCount FROM Station;" )( result );
        count = result.row.StationCount
    }]
    [ getByMessGroup( messGroup )( messGroupDataResponse  ) {
        query = "SELECT * FROM StationData sd INNER JOIN Station s ON s.stationID = sd.stationID WHERE sd.messGroup = :messGroup;";
        query.messGroup = messGroup;
        query@Database( query )( messGroupDataResponse )
    }]
    /* This will lead to memory issues
    [ getByStation ( stationID )( data ) {
        query = "SELECT * FROM Station s INNER JOIN StationData sd ON sd.stationID = s.stationID WHERE sd.stationID = :stationID;";
        query.stationID = stationID;
        query@Database( query )( data );
        valueToPrettyString@StringUtils( data )( re );
        println@Console( re )()
    }] */
    [ getStations ( void )( stations ) {
        query = "SELECT * FROM Station;";
        query@Database( query )( stations );
        valueToPrettyString@StringUtils( stations )( s );
        println@Console( s )()
    }]
}

define tryCreateDBTables
{
    updateStation = "CREATE TABLE IF NOT EXISTS Station " +
                    "(status NVARCHAR(200), direction NVARCHAR(200), expectedInterval NVARCHAR(200), " +
                    " longtitude REAL, stationType NVARCHAR(255), name NVARCHAR(255), installDate NVARCHAR(30), " +
                    " source NVARCHAR(255), stationID NVARCHAR(255) UNIQUE, lattitude REAL);";
    update@Database( updateStation )();

    updateData = "CREATE TABLE IF NOT EXISTS StationData " +
                 "(lane NVARCHAR(255), display NVARCHAR(20), flash NVARCHAR(20), stationID NVARCHAR(255), datetime NVARCHAR(30), " +
                 " length NVARCHAR(20), messGroup NVARCHAR(255), gap NVARCHAR(255), speed NVARCHAR(20), class NVARCHAR(20), wrong_dir NVARCHAR(20)); ";

    update@Database( updateData )()
}

define validateAuthenticationKey
{
    if ( HARDCODED_VALUE == receiveRequest.authenticationKey )
        accepted = true
    else
        accepted = false
}

define addStationToDB
{
    update =
    "INSERT INTO Station " +
    "VALUES (:status, :direction, :expectedInterval, " +
    " :longtitude, :stationType, :name, :installDate, " +
    " :source, :stationID, :lattitude);";
    with ( receiveRequest.data ) {
        update.status = .status; update.direction = .direction; update.expectedInterval = .expectedInterval;
        update.longtitude = double( .longtitude ); update.stationType = .stationType; update.name = .name;
        update.installDate = .installDate; update.source = .source; update.stationID = .stationID;
        update.lattitude = double( .lattitude )
    };
    update@Database( update )( )
}

define addStationDataToDB
{
    update =
    "INSERT INTO StationData " +
    "VALUES (:lane, :display, :flash, :stationID, :datetime, " +
    " :length, :messGroup, :gap, :speed, :class, :wrong_dir); ";
    with ( receiveRequest.data ) {
        update.lane = .lane; update.display = .display;
        update.flash = .flash; update.stationID = .stationID; update.datetime = .datetime;
        update.length = .length; update.messGroup = .messGroup; update.gap = .gap;
        update.speed = .speed; update.class = .class; update.wrong_dir = .wrong_dir
    };
    update@Database( update )( )
}

define initConnection
{
    with (connectionInfo) {
        .username = .password = .host = "";
        .database = global.databaseName;
        .driver = "sqlite";
        .checkConnection = 1
    };
    connect@Database( connectionInfo )( )
}
