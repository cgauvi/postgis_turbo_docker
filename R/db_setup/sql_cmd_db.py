# Python script to run a few sql queries (mlti-statement) against a postgis db to create new fields in tables + functions to find addresses
# Author: Charles Gauvin 
# Note: DBI::dbexecute cannot run multi sql statements in R
# Nte 2: env variables saved in ../.env file (relative to script)

# Libs 
from pathlib import Path
from dotenv import load_dotenv, find_dotenv
load_dotenv( Path (find_dotenv() ).parent / '.env')

import psycopg2



# Conenct to dev db
conn_params= {    
    "host": environ['POSTGRES_HOST_DEV'],
    "database":environ['POSTGRES_DBNAME'],
    "user":environ['POSTGRES_USER'],
    "password":environ['POSTGRES_PASSWORD'],
    "port":environ['POSTGRES_PORT_DEV']
}

# list all sql comands IN ORDER they should be executed
ordred_list_scripts = [
    SQL_PATH / 'ts'/ 'add_city_name_new_tbl.sql',
    SQL_PATH / 'ts'/  'create_ts_address.sql',
    SQL_PATH / 'ts'/  'address_query_fcts.sql',
    #   #
    #   #
    SQL_PATH / 'mvt_buildings'  / 'create_agg_geohash.sql',
    SQL_PATH / 'mvt_buildings' / 'mvt_from_buildings.sql',
    SQL_PATH / 'mvt_buildings' / 'mvt_geom_from_buildings.sql',
    #   #
    #   #
    SQL_PATH / 'mvt_tax' / 'mvt_from_points.sql',
    SQL_PATH / 'mvt_tax' /  'mvt_tax/mvt_geom_from_tax.sql',
    SQL_PATH / 'mvt_tax' /  'mvt_tax/mvt_from_tax.sql'   
]

# load the sql files and run the scripts
for script in ordred_list_scripts:
    with open(script,'r') as file_r:
        with psycopg2.connect(**conn_params) as conn:
            print(f'Running {file_r.read()} ... ')
            cur = conn.cursor()
            cur.execute(file_r.read())
            conn.commit()
            
print(f'Successfully ran all {len(ordred_list_scripts)} sql scripts against db')