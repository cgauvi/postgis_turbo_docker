# Overview

These scripts were created to assist in the docker container management, infrastructure testing and showcase the benefits of using a postgres (+postgis) db with additional services like pg tile serv for web mapping and pg feature serv for sharing gis data.


# Setup

The connection credentials should be placed in a `.Renviron` file here (ie at the root of `R`)

Sample file should look like:

```
POSTGRES_CONNECTION_STRING="postgresql:/xxx:sss@sss:ccc/aaaa"
POSTGRES_USER="xxxx"
POSTGRES_DBNAME="xxx"
POSTGRES_PORT=xx
POSTGRES_PORT_DEV=xx
POSTGRES_PASSWORD="xxx"
```

# Demo

Showcase ways to use the 2 services (currently only pg feature serv deployed on the test on-prem ssq server)

- consume feature serv
  - show how to build a simple iterator to read larger geo spatial tables
- consume tileserv 
  - basic leaflet code to show how to use vector tiles in maps
  
  
# Tests

- Tests to make sure access rights have been set up correctly 