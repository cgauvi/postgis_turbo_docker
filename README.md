
# Postgis & auxiliary services docker image

## Overview

This repo provides a basic setup to create a postgis db with additional extensions & auxiliary services. 

- postgis db with read only user + dedicated public schema `postgisftw` schema for better flexibility & security

- postgis extensions for address full text search & tokenization
    - `address_standardizer`
    - `addressing_dictionary`

- `pg_tile_serv`
    - for mapbox vector tile serving on-the-fly from the db
    - varnish cache on top to speed up loading

- `pg_feature_serv`
    - for feature serving from db as geojson

- mbtile server
    - for serving of local mbtiles (produced by tippecanoe - see [this docker repo](https://github.com/cgauvi/tippecanoe_docker))

- nginx to serve html web pages that consume the apis above

## Dependencies

Running examples in this repo requires:

- Docker-compose >= V2


## Usage

Clone the repo

```
git clone https://github.com/cgauvi/postgis_turbo_docker.git
```

Get the configuration file with env variables `.env` and place it in `./config/.env`

Build the containers, volumes and network from within the docker directory:

```
cd docker
docker compose -f docker-compose.yml --env-file ./config/.env up
```
