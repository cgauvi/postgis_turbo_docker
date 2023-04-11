### setup #### 

# db parameters
dbname= Sys.getenv("POSTGRES_DBNAME")
host = 'localhost'
user = Sys.getenv("POSTGRES_USER")
password = Sys.getenv("POSTGRES_PASSWORD")
port= Sys.getenv("POSTGRES_PORT")

# Connect as admin
conn_admin <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= dbname,
  host = host,
  user = user,
  password = password,
  port= port
)


#### ogr2ogr commands to load data  ### 
list_ogr_cmd <- c('GIC_geo_muni' = glue::glue('ogr2ogr  -a_srs   \'EPSG:4326\'     -progress  "PG:host={host} dbname={dbname} user={user} password={password} port={port}"    -lco SCHEMA=public -lco GEOMETRY_NAME=geom "C:/Users/app12621/Dev/GIC_VEXCEL/data/qc_muni.gpkg" -nln GIC_geo_muni -lco PG_USE_COPY=YES'),
                  'GIC_geo_role_eval_cleaned_pc_adm_da' = glue::glue( 'ogr2ogr -a_srs \'EPSG:3347\' -progress  "PG:host={host} dbname={dbname} user={user} password={password} port={port}"  -lco SCHEMA=public   -lco GEOMETRY_NAME=geom  "C:/Users/app12621/Dev/GIC_VEXCEL/data/GIC_geo_role_eval_cleaned_pc_adm_da/GIC_geo_role_eval_cleaned_pc_adm_da.gpkg" -nln GIC_geo_role_eval_cleaned_pc_adm_da -lco PG_USE_COPY=YES'),
                  'building_footprints_open_data' =  glue::glue('ogr2ogr -progress -a_srs \'EPSG:3347\' "PG:host={host} dbname={dbname} user={user} password={password} port={port}" -lco SCHEMA=public   -lco GEOMETRY_NAME=geom   "C:/Users/app12621/Dev/GIC_VEXCEL/data/DB_EXPORT_export_buildings/buildings.shp" -nln building_footprints_open_data -lco PG_USE_COPY=YES -nlt MULTIPOLYGON'),
                  'cadastres' = glue::glue('ogr2ogr -progress -a_srs \'EPSG:3347\' "PG:host={host} dbname={dbname} user={user} password={password} port={port}" -lco SCHEMA=public   -lco GEOMETRY_NAME=geom  "C:/Users/app12621/Dev/GIC_VEXCEL/data/DB_EXPORT_export_cadastres/cadastres.shp" -nln cadastres -lco PG_USE_COPY=YES -nlt MULTIPOLYGON')
                   )


lapply(seq_along(list_ogr_cmd), function(x){
  
  tbl_name <-  tolower(names(list_ogr_cmd)[[x]])

  # Populate DB by uploading tables
  if(!RPostgres::dbExistsTable(conn_admin, tbl_name)){
    system(x)
  }else{
    print(glue::glue('Table {tbl_name} already exists'))
  }
})
 

#### tbl modification / sql commands for mvt  ### 

# Apply all relevant sql commands in order 
list_sql_commands <- c(
  '../sql/ts/add_city_name_new_tbl.sql',
  '../sql/ts/create_ts_address.sql',
  '../sql/ts/address_query_fcts.sql',
  #
  #
  '../mvt_buildings/create_agg_geohash.sql',
  '../mvt_buildings/mvt_from_buildings.sql',
  '../mvt_buildings/mvt_geom_from_buildings.sql',
  #
  #
  '../mvt_tax/mvt_from_points.sql',
  '../mvt_tax/mvt_geom_from_tax.sql',
  '../mvt_tax/mvt_from_tax.sql'
)


lapply(list_sql_commands, function(x){
  
  cmd <- paste0(readLines(x), sep='', collapse = ' ')
  print(glue::glue("Running {cmd}..."))
  
  RPostgres::dbExecute(
    conn = conn_admin,
    statement = cmd
  )
  
  
})
