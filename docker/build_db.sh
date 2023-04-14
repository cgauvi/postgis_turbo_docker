 #! /bin/bash 
 
# Download repo
if [ ! -d ./libpostal ]; then
    git clone --depth 1 --branch v1.0.0 https://github.com/openvenues/libpostal ./libpostal
    find ./libpostal -type f -print0 | xargs -0 dos2unix
else
    echo "Already cloned repo libpostal.."
fi

# Download data
chmod u+x ./dl_postal_lib.sh
dos2unix ./dl_postal_lib.sh
./dl_postal_lib.sh

# Convert scripts to UNIX format: new lines
dos2unix ./build_libpostal_data.sh
dos2unix ./build_libpostal.sh

# Download pgsql
if [ ! -d ./pgsql-postal ]; then
    git clone --depth 1 --branch master https://github.com/pramsey/pgsql-postal ./pgsql-postal
    find ./pgsql-postal -type f -print0 | xargs -0 dos2unix
else
    echo "Already cloned repo pgsql-postal.."
fi


docker compose -f docker-compose.yml --env-file ./config/.env build db
# To run:
# docker compose -f docker-compose.yml --env-file ./config/.env run db
