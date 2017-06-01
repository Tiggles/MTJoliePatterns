cd CBLiveParking
jolie circuitbreaker.ol &
cd ../CBParking
jolie circuitbreaker.ol &
cd ../CBTrafficATKI
jolie circuitbreaker.ol &
#cd ../CBParkingWWW
#jolie circuitbreaker.ol &
cd ../CBServiceRegistry
jolie circuitbreaker.ol &
cd ..
cd ServiceRegistry
jolie ServiceRegistryLayer.ol &
echo ServiceRegistry
cd db
jolie initDB.ol
echo InitDB
jolie ServiceRegistry.ol &
echo StatsDB
cd ..
echo Services
jolie website.ol &
cd Services
sleep 1
echo
echo PARKINGSERVICE
echo
jolie ParkingService.ol &
sleep 1
echo
echo LiveParking
echo
jolie LiveParking.ol &
cd ParkingWWW
sleep 1
echo
echo ParkingWWW
echo
jolie ParkingServiceWWW.ol &
cd ../TrafficATKI
jolie TrafficATKI.ol &
