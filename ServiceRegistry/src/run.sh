jolie ServiceRegistryLayer.ol &
echo ServiceRegistry
cd db
jolie initDB.ol
echo InitDB
jolie ServiceRegistry.ol &
echo StatsDB
cd ..
jolie website.ol &
cd Services
echo services
jolie ParkingService.ol &
jolie LiveParking.ol &
cd ParkingWWW
jolie ParkingServiceWWW.ol &
echo
echo
echo
echo traffic
cd ../TrafficATKI
jolie TrafficATKI.ol &
