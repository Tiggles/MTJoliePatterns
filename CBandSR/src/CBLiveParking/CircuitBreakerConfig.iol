include "../ServiceRegistry/Services/LiveParking.iol"

constants {
    CIRCUITBREAKER_LOCATION = "socket://localhost:8004", // CHANGE DEPENDING ON CB LOCATION
    SERVICE_LOCATION = "socket://localhost:8005", // CHANGE DEPENDING ON SERVICE LOCATION
    SERVICE_INTERFACE = LiveParkingInterface, // CHANGE DEPENDING ON SERVICE INTERFACE
    CIRCUITBREAKER_PROTOCOL = http
}

outputPort Service {
    Location: SERVICE_LOCATION
    Protocol: http
    Interfaces: LiveParkingInterface // CHANGE DEPENDING ON SERVICE INTERFACE; IF OUTPUTPORT ADDS CHECKCONSTANTS, THIS CAN BE REPLACED
}
