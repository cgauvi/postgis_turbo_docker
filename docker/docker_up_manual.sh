#! /bin/bash

# Read in the env vars
source ./set_env_vars.sh

# ===== network =====
result=$( docker network ls | awk '{ print $2 }' | grep 'pgNetManual' )
if [[ -z "$result" ]]; then
    docker network create pgNetManual \
    --attachable
else
    echo "network pgNetManual already exists"
fi


# ==== Named volume ======
docker volume create pgDataManual
# get back the volume location on the host with:
# `docker inspect pgDataManual -f '{{.Mountpoint}}'`

# ===== build images =====
## postgis DB
result=$( docker images -q docker_db_manual )
if [[ -z "$result" ]]; then
    docker build -f ./Dockerfile.postgis.psql_address_dict.kartoza \
    -t docker_db_manual \
    --build-arg POSTGRES_CONNECTION_STRING=$POSTGRES_CONNECTION_STRING \
    --build-arg POSTGRES_CONNECTION_STRING_RO=$POSTGRES_CONNECTION_STRING_RO \
    --build-arg POSTGRES_USER=$POSTGRES_USER\
    --build-arg POSTGRES_DBNAME=$POSTGRES_DBNAME\
    --build-arg POSTGRES_PASSWORD=$POSTGRES_PASSWORD\
    --build-arg POSTGRES_USER_RO=$POSTGRES_USER_RO\
    --build-arg POSTGRES_PASSWORD_RO=$POSTGRES_PASSWORD_RO\
    --build-arg POSTGRES_SCHEMA_PUBLIC_FACING=$POSTGRES_SCHEMA_PUBLIC_FACING \
    .
else
    echo "postgis image already exists"
fi


## pg feature serv
result=$( docker images -q pramsey/pg_featureserv:latest )
if [[ -z "$result" ]]; then
    docker image pull pramsey/pg_featureserv:latest
else
    echo "feature serv image already exists"
fi


## pg tile serv
result=$( docker images -q pramsey/pg_tileserv:latest )
if [[ -z "$result" ]]; then
    docker image pull pramsey/pg_tileserv:latest
else
    echo "pg_tileserv image already exists"
fi


## varnish cache
result=$( docker images -q eeacms/varnish:latest )
if [[ -z "$result" ]]; then
    docker image pull eeacms/varnish:latest
else
    echo "varnish image already exists"
fi

## mbtile server
result=$( docker images -q consbio/mbtileserver:latest )
if [[ -z "$result" ]]; then
    docker image pull consbio/mbtileserver:latest
else
    echo "mbtile server image already exists"
fi

## nginx
result=$( docker images -q nginx:latest )
if [[ -z "$result" ]]; then
    docker image pull nginx:latest
else
    echo "nginx image already exists"
fi

# ===== Run ===== 

## postgis 
if [ "$(docker ps -aq -f status=exited -f name=docker_db_manual_run)" ]; then
        # cleanup
        echo "Cleaning up .. container docker_db_manual_run already exists "
        docker rm docker_db_manual_run
fi

if [ "$( docker container inspect -f '{{.State.Running}}' 'docker_db_manual_run' )" != "true" ];  then
        ## postgis DB
        docker run -d \
        -e POSTGRES_CONNECTION_STRING=$POSTGRES_CONNECTION_STRING \
        -e POSTGRES_CONNECTION_STRING_RO=$POSTGRES_CONNECTION_STRING_RO \
        -e POSTGRES_USER=$POSTGRES_USER\
        -e POSTGRES_DBNAME=$POSTGRES_DBNAME\
        -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD\
        -e POSTGRES_USER_RO=$POSTGRES_USER_RO\
        -e POSTGRES_PASSWORD_RO=$POSTGRES_PASSWORD_RO\
        -e POSTGRES_SCHEMA_PUBLIC_FACING=$POSTGRES_SCHEMA_PUBLIC_FACING \
        -e POSTGRES_HOST_AUTH_METHOD=trust \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        --network pgNetManual \
        --volume pgDataManual:/var/lib/postgresql/data \
        -p 5053:5432 \
        --name docker_db_manual_run \
        --health-cmd "pg_isready -d gis" \
        --health-interval 30s \
        --health-timeout 60s \
        --health-retries 5 \
        --health-start-period 80s \
        docker_db_manual 
else
        echo "docker_db_manual container already running"
fi 

 
# Health check
until [ "`docker inspect -f {{.State.Health.Status}} docker_db_manual_run`"=="healthy" ]; do
    sleep 0.1;
    echo 'waiting on healthy db container ... '
done;
echo 'db healthy ... '

## pg feature serv
if [ "$(docker ps -aq -f status=exited -f name=featureserv_config_run)" ] || [ "$(docker ps -aq -f status=created -f name=featureserv_config_run)" ]; then
        # cleanup
        echo "Cleaning up .. container featureserv_config_run already exists "
        docker rm featureserv_config_run
fi

if [ "$( docker container inspect -f '{{.State.Running}}' 'featureserv_config_run' )" != "true" ]; then
        docker run -d \
        -e DATABASE_URL=$POSTGRES_CONNECTION_STRING_RO \
        --network pgNetManual \
        -p 5054:9000 \
        -v "$(pwd)"/config/featureserv_config.toml:/app/config.toml \
        --name featureserv_config_run \
        --health-cmd "pg_isready -d gis" \
        pramsey/pg_featureserv:latest \
        '--config' '/app/config.toml'
else
        echo "featureserv_config_run container already running"
fi 



## pg tile serv 
if [ "$(docker ps -aq -f status=exited -f name=tileserv_run)" ] || [ "$(docker ps -aq -f status=created -f name=tileserv_run)" ]; then
        # cleanup
        echo "Cleaning up .. container tileserv_run already exists "
        docker rm tileserv_run
fi

if [ "$( docker container inspect -f '{{.State.Running}}' 'tileserv_run' )" != "true" ]; then
        docker run -d \
        -e DATABASE_URL=$POSTGRES_CONNECTION_STRING_RO \
        --network pgNetManual \
        -p 5055:7800 \
        -v "$(pwd)"/config/tileserv_config.toml:/app/config.toml \
        --name tileserv_run \
        pramsey/pg_tileserv:latest \
        '--config' '/app/config.toml'
else
        echo "tileserv_run container already running"
fi 



## varnish cache
if [ "$(docker ps -aq -f status=exited -f name=varnish_run)" ] || [ "$(docker ps -aq -f status=created -f name=varnish_run)"  ]; then
        # cleanup
        echo "Cleaning up .. container varnish_run already exists "
        docker rm varnish_run
fi

if [ "$( docker container inspect -f '{{.State.Running}}' 'varnish_run' )" != "true" ]; then
        docker run -d \
        -e  BACKENDS='tileserv_run:7800' \
        -e DNS_ENABLED='false' \
        -e COOKIES='true' \
        -e PARAM_VALUE='-p default_ttl=600' \
        --network pgNetManual \
        -p 80:6081 \
        --name varnish_run \
       eeacms/varnish:latest 
else
        echo "varnish_run container already running"
fi 



## mbtile serv
if [ "$(docker ps -aq -f status=exited -f name=mbtileserver_run)" ] || [ "$(docker ps -aq -f status=created -f name=mbtileserver_run)"  ]; then
        # cleanup
        echo "Cleaning up .. container mbtileserver_run already exists "
        docker rm mbtileserver_run
fi

if [ "$( docker container inspect -f '{{.State.Running}}' 'mbtileserver_run' )" != "true" ]; then
        docker run -d \
        -v "$(pwd)"/../tiles:/opt/tippecanoe/tiles \
        --network pgNetManual \
        -p 5056:8000 \
        --name mbtileserver_run \
        --entrypoint '/mbtileserver'  \
       consbio/mbtileserver:latest \
       --enable-reload-signal --dir /opt/tippecanoe/tiles
else
        echo "mbtileserver_run container already running"
fi 



## nginx
if [ "$(docker ps -aq -f status=exited -f name=nginx_run)" ] || [ "$(docker ps -aq -f status=created -f name=nginx_run)" ]; then
        # cleanup
        echo "Cleaning up .. container nginx_run already exists "
        docker rm nginx_run
fi

if [ "$( docker container inspect -f '{{.State.Running}}' 'nginx_run' )" != "true" ]; then
        docker run -d \
        -v "$(pwd)"/../html:/usr/share/nginx/html \
        --network pgNetManual \
        -p 8000:80 \
        --name nginx_run \
        --health-cmd "pg_isready -d gis" \
       nginx:latest 
else
        echo "nginx_run container already running"
fi 