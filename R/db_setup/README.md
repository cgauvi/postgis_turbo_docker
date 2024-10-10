
# Overview

These are shitty R scripts to semi-manually populate the DB & setup the services on top


## DB creation

1. First db_transfer should be run (once the actual prod db has been set up an is running)
2. Next, the user privileges should be granted. For automatic privileges, need to alter default privileges as the admin user that created the tables. Otherwise, need to run these scripts as said admin user
3. Run the sql scripts to create functions that can be exposed with pg feature serv. 

## SQL scripts

Presently the DB is set can be configured by either 

1. manually running the following sql commands (in the following order) in pgadmin:

   - `here::here('../sql/ts/add_city_name_new_tbl.sql')`,
   - `here::here('../sql/ts/create_ts_address.sql')`,
   - `here::here('../sql/ts/address_query_fcts.sql')`,
   
   
   - `here::here('../mvt_buildings/create_agg_geohash.sql')`,
   - `here::here('../mvt_buildings/mvt_from_buildings.sql')`,
   - `here::here('../mvt_buildings/mvt_geom_from_buildings.sql')`,
   
   
   - `here::here('../mvt_tax/mvt_from_points.sql')`,
   - `here::here('../mvt_tax/mvt_geom_from_tax.sql')`,
   - `here::here('../mvt_tax/mvt_from_tax.sql')`
   
   
  Where `here::here()` should point to `R` folder
   

  
   
2. The 2nd (buggy but semi working) options is to run these multi statements scripts semi automcaticall in python using `R/db_setup/db_populate.R` (from within `R/db_setup/`). _Note_: running multi statement sql commands always leads to errors. 