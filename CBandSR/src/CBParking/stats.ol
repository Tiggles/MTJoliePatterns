include "console.iol"
include "stats.iol"
include "math.iol"
include "time.iol"
include "database.iol"
include "exec.iol"
include "file.iol"
include "string_utils.iol"


execution { concurrent } // Either sequential or make atomic when incrementing values

constants {
    tripThreshold = 0.05, // 5 percent
    rollingWindowTimeValue = 30000, // 30 seconds in milliseconds
    usesRandomDoubleForCheckRate = false,
    lowerBound = 5,
    totalRollingWindows = 5,
    requestsPerRollingWindowAllowed = 64,
    randomLowerValue = 0.10,
    timeSinceLastFailureAllowed = 90000, // 90 seconds in milliseconds
    useTimerForClosing = true,
    debug = false,
    DB_NAME_PREFIX = "CB"
}

init {
    global.totalSuccesses = 0;
    global.totalFailures = 0;
    global.totalTimeouts = 0;

    getCurrentTimeMillis@Time()( global.lastFailure );

    resetRollingWindowValues;
    resetRollingWindows;
    global.rollingWindowIndex = 0;
    scheduleTimeout@Time( rollingWindowTimeValue { .operation = "nextRollingWindow" } )( );

    if ( debug ) { initDB; scheduleTimeout@Time( 60000 { .operation = "outputStatsToDB" } )( ) }
}

inputPort localIn {
    Location: "local"
    Interfaces: IfaceStats
}

// Use if not embedded
/*inputPort Stats {
    Location: "socket://localhost:8080"
    Protocol: sodep
    Interfaces: IfaceStats
}*/

main {
    [ timeout() ] {
        getCurrentTimeMillis@Time()( now );
        synchronized ( syncToken ) {
            global.lastFailure = now;
            global.rollingWindows[global.rollingWindowIndex].timeouts++;
            global.totalTimeouts++
        }
    }
    [ reset() ] {
        synchronized ( syncToken ) {
            resetRollingWindows
        }
    }
    [ failure() ] {
        getCurrentTimeMillis@Time()( now );
        synchronized ( syncToken ) {
            global.totalFailures++;
            global.rollingWindows[global.rollingWindowIndex].failures++;
            global.lastFailure = now

        }
    }
    [ success() ] {
        synchronized ( syncToken ) {
            global.rollingWindows[global.rollingWindowIndex].successes++;
            global.totalSuccesses++
        }
    }
    [ checkRate( )( canPass )  {
        // Either random or using rollingWindow
        canPass = false;
        if ( usesRandomDoubleForCheckRate ) {
            random@Math( )( randDouble );
            if ( randDouble >= randomLowerValue ) {
                canPass = true
            }
        }
        else { // Use rolling window approach (this is the default)
            getTotalFailuresAndTimeouts;
            if ( total < requestsPerRollingWindowAllowed ) {
                canPass = true
            }
        }
    }]
    [ shouldTrip( )( trip ) {
        trip = false;
        getTotalFailuresAndTimeouts;
        if (total != 0) {
            if ( double( totalFailuresAndTimeouts ) / double( total ) >= tripThreshold) {
                trip = true
            }
        }
    }]
    [ getStability( )( stable ) {
        stable = false;
        if ( useTimerForClosing ) {
            with( global.rollingWindowValues ) {
                getCurrentTimeMillis@Time( )( now );
                if ( global.lastFailure + timeSinceLastFailureAllowed < now ) {
                    stable = true
                }
            }
        } else {
            getTotalFailuresAndTimeouts;
            if (total != 0) {
                if (  total  >= lowerBound ) {
                    stable = true
                }
            }
        }
    } ]
    [ outputStatsToDB( ) ] {
        outputStatsToDB
    }
    [ nextRollingWindow( ) ] {
        getTotalFailuresAndTimeouts;

        global.rollingWindowIndex = ( global.rollingWindowIndex + 1 ) % totalRollingWindows;
        global.rollingWindows[global.rollingWindowIndex].successes = 0;
        global.rollingWindows[global.rollingWindowIndex].failures = 0;
        global.rollingWindows[global.rollingWindowIndex].timeouts = 0;
        scheduleTimeout@Time( rollingWindowTimeValue { .operation = "nextRollingWindow" } )( )
    }
}

define resetRollingWindowValues
{
    getCurrentTimeMillis@Time()( currentTimeMillis );
    with ( global.rollingWindowValues ) {
        if ( debug ) {
            println@Console("next reset: " + .nextResetInMillis)();
            println@Console("reqs: " + .totalRequests)()
        };
        .nextResetInMillis = currentTimeMillis + rollingWindowTimeValue;
        .totalRequests = 0
    }
}

define resetRollingWindows
{
    for ( i = 0, i < totalRollingWindows, i++ ) {
        with ( global.rollingWindows[i] ) {
            .successes = 0;
            .failures = 0;
            .timeouts = 0
        }
    }
}

define getTotalFailuresAndTimeouts
{
    total = 0;
    totalFailuresAndTimeouts = 0;
    totalSuccesses = 0;
    for ( i = 0, i < totalRollingWindows, i++ ) {
        with ( global.rollingWindows[i] ) {
            total += .successes;
            total += .failures;
            total += .timeouts;
            totalSuccesses += .successes;
            totalFailuresAndTimeouts += .failures;
            totalFailuresAndTimeouts += .timeouts
        }
    }
}

define initConnection
{
    with ( connectionInfo )
    {
        .username = .password = .host = "";
        .database = global.databaseName;
        .driver = "sqlite";
        .checkConnection = 1
    };
    connect@Database( connectionInfo )( )
}

define tryCreateDatabaseFile
{
    exists@File( global.databaseName )( exists );
    if ( !exists )
    {
        commandExecutionRequest = "touch";
        with ( commandExecutionRequest ) {
            .args[0] = global.databaseName;
            .waitFor = 1
        };
        exec@Exec( commandExecutionRequest )( execResult )
    }
}

define initDB
{
    getCurrentDateTime@Time( )( time );
    global.databaseName = DB_NAME_PREFIX + ".db";
    tryCreateDatabaseFile;
    initConnection;
    tableCommand =
    "CREATE TABLE IF NOT EXISTS Stats " +
    "(time NVARCHAR(50), successes BIGINT, failures BIGINT, timeouts BIGINT)";
    update@Database( tableCommand )()

}

define outputStatsToDB
{
    getCurrentDateTime@Time( )( time );
    commandString =
    "INSERT INTO Stats " +
    "VALUES ('" + time + "', " + global.totalSuccesses + ", " + global.totalFailures + ", " + global.totalTimeouts + ") ";
    update@Database( commandString )( );
    scheduleTimeout@Time( 60000 { .operation = "outputStatsToDB" } )()
}
