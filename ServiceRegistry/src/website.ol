include "console.iol"
include "file.iol"
include "string_utils.iol"
include "time.iol"
include "ServiceRegistryLayer.iol"

interface PingIface {
    RequestResponse:
        ping( void )( void )
}

outputPort PingExtService {
    Interfaces: PingIface
}


execution{ concurrent }

constants {
    rootFolder = "www/",
    tableHeader = "<table class='ui celled table'>
                  <thead>
                    <tr>
                      <th>Servicename</th>
                      <th>Owner</th>
                      <th>Location</th>
                      <th>Protocol</th>
                      <th>Interface</th>
                      <th>Documentation</th>
                    </tr>
                  </thead>
                  <tbody>",
    tableFooter = "</tbody></table>"
}

interface WebsiteInterface {
    RequestResponse:
        default( undefined )( undefined ),
        searchByName( undefined )( undefined ),
        about( undefined )( undefined ),
        setup( undefined )( undefined ),
        getInterfaceFile( undefined )( undefined ),
        getServiceDocFile( undefined )( undefined ),
        pingService( undefined )( undefined ),
        shutdown( void )( void )
    OneWay:
        // NONE
}

inputPort WebsitePort {
    Location: "socket://localhost:8000"
    Protocol: http { .format -> format; .contentType -> mime; .default = "default"; .contentDisposition -> contentDisposition }
    Interfaces: WebsiteInterface
}

main {
    [ default( request )( response )
    {
        format = "html";
        println@Console( request.operation )();
        contains@StringUtils( request.operation { .substring = ".." } )( reversePathTraversal );
        if (request.operation == "" || reversePathTraversal )
        {
            request.operation = "index.html"
        };
        exists = false;
        if ( reversePathTraversal == false ) {
            exists@File( rootFolder + operation.request )( exists )
        };

        if (!exists)
        {
            request.operation = "index.html"
        };
        readFile@File( { .filename = rootFolder + request.operation } )( response )
    }]
    [ searchByName( request )( response ) {
        if ( request.query == "" ) request.query = "%%";
        searchServices@ServiceRegistry( request.query )( queryResult );
        response.msg = tableHeader;
        buildTable;
        response.msg += tableFooter
    }]
    [ getInterfaceFile( request )( response ) {
        if (request.query == "registering.ol") {
            contentDisposition = "attachment; filename=\"registering.ol\"";
            format = "raw";
            mime = "application/x-jolie-source ol";
            readFile@File( { .filename = rootFolder + "registering.ol" })( response )
        } else {
            contentDisposition = "attachment; filename=\"" + request.query + ".iol\"";
            format = "raw";
            mime = "application/x-jolie-interface";
            getServiceInterface@ServiceRegistry( request.query )( response )
        }
    }]
    [ getServiceDocFile( request )( response ) {
        format = "html";
        getServiceDocFile@ServiceRegistry( request.query )( response )
    }]
    [ about( )( response ) {
        readFile@File( { .filename = rootFolder + "about" } )( response );
        response.msg = response
    }]
    [ setup( )( response ) {
        readFile@File( { .filename = rootFolder + "setup" } )( response );
        response.msg = response
    }]
    [ pingService( req )( res ) {
        scope( pingScope )
        {
            install( default => res.msg = "<script>prompt(\"Failed to connect to service\")</script>" );
            split@StringUtils( req.query { .regex = "%" } )( res );
            PingExtService.location = res;
            PingExtService.protocol = res;
            getCurrentTimeMillis@Time()( before );
            ping@PingExtService()();
            getCurrentTimeMillis@Time()( after);
            res.msg = "<script>prompt(\"Service responded in " + ( after - before ) + " milliseconds\")</script>"
        }
    }]
    [ shutdown( )( ) {
        exit
    }]
}

define buildTable
{
    for (i = 0, i < #queryResult.row, i++) {
        with ( queryResult.row[i] ) {
            response.msg += "<tr>
                              <td>" + .Name + "</td>
                              <td>" + .OwnerName + "</td>
                              <td>" + .Location + "</td>
                              <td>" + .Protocol + "</td>
                              <td>
                                <button class='ui primary button downloadButton'>
                                    <a href='getInterfaceFile?query=" + .Name + "' target='_blank'>Download Interface</a>
                                </button>
                              </td>
                              <td>
                               <button class='ui secondary button downloadButton'>
                                    <a href='getServiceDocFile?query=" + .Name + "' target='_blank'>Show Documentation</a>
                               </td>
                             </tr>"
        }
    }
}
