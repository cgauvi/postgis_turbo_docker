#!/bin/bash

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the test db
#https://github.com/kartoza/docker-postgis/blob/develop/scripts/setup-database.sh
db='test'
RESULT=`su - postgres -c "psql -t -c \"SELECT count(1) from pg_database where datname='${db}';\""`
if [[  ${RESULT} -eq 0 ]]; then
    echo -e "\e[32m [Entrypoint] Create database \e[1;31m ${db}  \033[0m"
    DB_CREATE=$(createdb -h localhost -p 5432 -U ${POSTGRES_USER} -T template_postgis --dbname ${db})
    eval ${DB_CREATE}
    psql -U ${POSTGRES_USER} -p 5432 -h localhost -c 'CREATE EXTENSION IF NOT EXISTS pg_cron cascade;'
else
    echo -e "\e[32m [Entrypoint] Database \e[1;31m ${db} \e[32m already exists \033[0m"

fi
 
# Add the postgisftw schema to expose public functions 
dbArrays=($POSTGRES_DBNAME 'test')
for DB in ${dbArrays[@]}; do
	echo "creating schema $POSTGRES_SCHEMA_PUBLIC_FACING for $DB"
    su - postgres -c "psql -d $DB -c \"CREATE SCHEMA IF NOT EXISTS $POSTGRES_SCHEMA_PUBLIC_FACING;\""
done

dbArrays=("$POSTGRES_DBNAME" "test")
extensions=("postgis" "postgis_topology" "fuzzystrmatch" "postgis_tiger_geocoder" "address_standardizer" "addressing_dictionary")

echo "creating extensions..."

# Load PostGIS extensions in $POSTGRES_DB + test
for DB in ${dbArrays[@]}; do
	for ext in ${extensions[@]}; do
		echo "Loading PostGIS extension $ext into $DB"
		psql -U $POSTGRES_USER  -p 5432 -h localhost  --dbname="$DB" -c " CREATE EXTENSION IF NOT EXISTS $ext;"
	done
done