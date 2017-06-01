include "mock_service.iol"
include "time.iol"

execution { concurrent }

inputPort MockService {
    Location: "socket://localhost:8000"
    Protocol: http
    Interfaces: MockServiceIface
}

main {
    [ req( request )( response ) {
        response.content = request.content
    }]
}
