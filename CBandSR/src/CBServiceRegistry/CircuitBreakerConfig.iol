include "../ServiceRegistry/ServiceRegistryLayer.iol"

constants {
    CIRCUITBREAKER_LOCATION = "socket://localhost:8001", // CHANGE DEPENDING ON CB LOCATION
    SERVICE_LOCATION = "socket://localhost:8002", // CHANGE DEPENDING ON SERVICE LOCATION
    SERVICE_INTERFACE = ServiceRegistryInterface, // CHANGE DEPENDING ON SERVICE INTERFACE
    CIRCUITBREAKER_PROTOCOL = http, // CHANGE DEPENDING ON PROTOCOL
}

outputPort Service {
    Location: SERVICE_LOCATION
    Protocol: http
    Interfaces: ServiceRegistryInterface // CHANGE DEPENDING ON SERVICE INTERFACE; IF OUTPUTPORT ADDS CHECKCONSTANTS, THIS CAN BE REPLACED
}
