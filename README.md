# Master Thesis Jolie Patterns

The three patterns are available to run by cloning this repository. Each instance of a circuit breaker will require the SQLite-jar file which is distributed once with this repo. It is available in the MTJoliePatterns/ServiceRegistry/src/db/ folder. This must be either added to the folder in which the Circuit Breaker is run, and the to TrafficATKI folder as well, or included in PATH.

The CBandSR is a combination of the Service Registry with the services hidden behind circuit breakers. An instance running is available at http://opendata.sdu.dk:8000
