#!/usr/bin/env bash

set -e

# This script will setup a new read only user for $POSTGRES_DBNAME 
# User will have connection access + read  on the $POSTGRES_DBNAME.$POSTGRES_SCHEMA_PUBLIC_FACING schema -> typically .gis.postgisftw  

# Taken from https://tableplus.com/blog/2018/04/postgresql-how-to-create-read-only-user.html
# https://www.crunchydata.com/blog/creating-a-read-only-postgres-user

{
    # Create RO user - if not exist - shity bash try catch
    # https://stackoverflow.com/questions/22009364/is-there-a-try-catch-command-in-bash
    echo "Running \"CREATE USER $POSTGRES_USER_RO ...; \""
    su - postgres -c "psql -d $POSTGRES_DBNAME -c \"CREATE USER $POSTGRES_USER_RO  NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN encrypted PASSWORD '$POSTGRES_PASSWORD_RO';\""
} || 
{
    echo "Error with \"CREATE USER $POSTGRES_USER_RO LOGIN PASSWORD xxx;\""
}
 
#### Public schema #####
echo "Securing DB by revoking from public ;\""
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"REVOKE ALL ON DATABASE $POSTGRES_DBNAME FROM PUBLIC;\""

echo "Granting minimum execute on public functions to $POSTGRES_USER_RO;\""
# Connect
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"GRANT CONNECT ON DATABASE $POSTGRES_DBNAME TO $POSTGRES_USER_RO;\""
# Schema 
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"GRANT USAGE ON SCHEMA public TO $POSTGRES_USER_RO;\""
# Tables  - read access only to public.spatial_ref_sys
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC ;\""
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"GRANT SELECT ON TABLE public.spatial_ref_sys TO $POSTGRES_USER_RO;\""
# Functions + procedures
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC ;\""
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO $POSTGRES_USER_RO;\""
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"REVOKE ALL ON ALL PROCEDURES IN SCHEMA public FROM PUBLIC ;\""
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO $POSTGRES_USER_RO;\""


#### $POSTGRES_SCHEMA_PUBLIC_FACING schema #####
echo "Granting execute + select on  $POSTGRES_SCHEMA_PUBLIC_FACING  on functions + tables ;\""
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"REVOKE USAGE ON SCHEMA $POSTGRES_SCHEMA_PUBLIC_FACING FROM PUBLIC;\""
# Schema 
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"GRANT USAGE ON SCHEMA $POSTGRES_SCHEMA_PUBLIC_FACING TO $POSTGRES_USER_RO;\""
# Tables - read access only
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"REVOKE ALL ON ALL TABLES IN SCHEMA $POSTGRES_SCHEMA_PUBLIC_FACING FROM $POSTGRES_USER_RO;\""
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"GRANT SELECT ON ALL TABLES IN SCHEMA $POSTGRES_SCHEMA_PUBLIC_FACING TO $POSTGRES_USER_RO;\""
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"ALTER DEFAULT PRIVILEGES IN SCHEMA $POSTGRES_SCHEMA_PUBLIC_FACING GRANT SELECT ON TABLES TO $POSTGRES_USER_RO;\""
# Functions
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA $POSTGRES_SCHEMA_PUBLIC_FACING  TO $POSTGRES_USER_RO;\""
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA $POSTGRES_SCHEMA_PUBLIC_FACING  TO $POSTGRES_USER_RO;\""
su - postgres -c "psql -d $POSTGRES_DBNAME -c \"ALTER DEFAULT PRIVILEGES IN SCHEMA $POSTGRES_SCHEMA_PUBLIC_FACING GRANT EXECUTE ON FUNCTIONS TO $POSTGRES_USER_RO;\"" # functions includes procedures - https://www.postgresql.org/docs/current/sql-alterdefaultprivileges.html



 