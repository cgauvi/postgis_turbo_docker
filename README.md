
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
- Docker (manual `docker/docker_up_manual.sh` script provided for convenience)


## Usage

1. Clone the repo

```
git clone https://github.com/cgauvi/postgis_turbo_docker.git
```

2. (optional) Create mbtiles (e.g. using a docker image from this [this repo](https://github.com/cgauvi/tippecanoe_docker)) and place them in `./tiles/`. _The tiles must be placed at this location BEFORE the mbtileserv service is started. Otherwise, files will not be detected_.



3. The images requires exposing a few ports. Make sure the following  are exposed and opened:

- Postgis db: 5052
- Tileserv (private): 5057 (only set up with compose)
- Tileserv (public): 5055
- Feature serv: 5054
- Mbtile serv: 5056
- Nginx: 8000 

4. Download data before building the container. Depending on your proxy, running `RUN curl --insecure xxx` or even `git clone https://github.com/` from within the container might fail. To avoid this issue, the dockerfile assumes some data is downloaded beforehand and placed in the `docker` directory. Run: (from the root)  

```{bash}
cd docker
./dl_postallib.sh
./dl_h3_github.sh # 
```

`./dl_postallib.sh` download the zipped libpostal weights to `docker/local_postal_lib_data`
`./dl_h3_github.sh` download the h3 source code repo. Seems useful since the repo is large and hungs indefinitely sometimes. A static dl upfront solves the problem.


5. Build and run the docker containers with docker-compose

- With `docker compose`

    - Get the configuration file with env variables `.env` and place it in `./config/.env`
    - Build the containers, volumes and network from within the docker directory:
```
cd docker
docker compose -f docker-compose.yml --env-file ./config/.env up
```


- With regular `docker`

    - Run `docker/set-env-vars.sh` with appropriate vars. See `docker/set-env-vars_sample.sh` for an example. 
    - Run the following:


```{bash}
cd docker
chmod u+x docker_up_manual.sh
./docker_up_manual.sh
```