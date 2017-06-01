type WeatherDayRequest: void {
    .country:string
    .zipcode:string
    .daysFromToday?:int
}

type WeatherDayResponse: void {
    .degrees[1,*]: double
    .weatherType[1,*]: string
}

type WeatherHourRequest: void {
    .country:string
    .zipcode:int
}

type WeatherHourResponse:void {
    .degrees[1,*]: double
    .weatherType[1,*]: string
}


interface FakeWeatherInterface {
    RequestResponse:
        getDayWeather( WeatherDayRequest )( WeatherDayResponse ),
        getHourWeather( WeatherHourRequest )( WeatherHourResponse )
    OneWay:
        shutdown( void )
}

outputPort WeatherExternalService {
    Interfaces: FakeWeatherInterface
}
