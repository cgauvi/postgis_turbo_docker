
# Postgis & auxiliary services docker image

This repo provides a basic setup to create a postgis db with additional extensions & auxiliary services. 


- postgis db with read only user + dedicated public schema postgisftw schema for better flexibility & security

- postgis extensions for address full textsearch & tokenization
    - address_standardizer
    - addressing_dictionary

- pg tile serv
    - for mapbox vector tile serving on-the-fly from the db
    - varnish cache on top to speed up loading

- pg feature serv
    - for feature serving from db as geojson

- mbtile server
    - for serving of local mbtiles (produced by tippecanoe - see [this docker repo](https://github.com/cgauvi/tippecanoe_docker))

- nginx to serve html web pages that consume the apis above

## Dependencies

Running examples in this repo requires:

- Docker-compose >= V2
