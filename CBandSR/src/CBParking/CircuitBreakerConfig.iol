include "../ServiceRegistry/Services/ParkingService.iol"

constants {
    CIRCUITBREAKER_LOCATION = "socket://localhost:8665", // CHANGE DEPENDING ON CB LOCATION
    SERVICE_LOCATION = "socket://localhost:8666", // CHANGE DEPENDING ON SERVICE LOCATION
    SERVICE_INTERFACE = ParkingServiceInterface, // CHANGE DEPENDING ON SERVICE INTERFACE
    CIRCUITBREAKER_PROTOCOL = sodep // CHANGE DEPENDING ON PROTOCOL
}

outputPort Service {
    Location: SERVICE_LOCATION
    Protocol: sodep
    Interfaces: ParkingServiceInterface // CHANGE DEPENDING ON SERVICE INTERFACE; IF OUTPUTPORT ADDS CHECKCONSTANTS, THIS CAN BE REPLACED
}