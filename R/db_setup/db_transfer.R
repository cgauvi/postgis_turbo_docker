### setup #### 

readRenviron ('../.Renviron')

# db source parameters
dbname= Sys.getenv("POSTGRES_DBNAME")
host_prod = Sys.getenv('POSTGRES_HOST_PROD')
user = Sys.getenv("POSTGRES_USER")
password = Sys.getenv("POSTGRES_PASSWORD")
port= Sys.getenv("POSTGRES_PORT")


# db destination parameters 
DEST_DB <- 'dev'
schema_dest <- 'postgisftw'

assertthat::assert_that(DEST_DB %in% c('dev', 'localhost'))
host_dest <- ifelse(DEST_DB == 'dev', Sys.getenv('POSTGRES_HOST_DEV'), 'localhost')
port_dest <- ifelse(DEST_DB == 'dev', Sys.getenv('POSTGRES_PORT_DEV'), Sys.getenv('POSTGRES_PORT') )

  
conn_dest <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= dbname,
  host =  host_dest,
  user = user,
  password = password,
  port= port_dest
)

 

#### ogr2ogr commands to transfer data  ### 
# Copy  from remote 'prod' db to local host
list_ogr_cmd <- c('gic_geo_role_eval_cleaned_pc_adm_da' = glue::glue( 'ogr2ogr -progress  
                                                                      -overwrite 
                                                                      --config PG_USE_COPY YES   
                                                                      "PG:host={host_dest} dbname={dbname} user={user} password={password} port={port_dest}" 
                                                                      "PG:host={host_prod} dbname={dbname} user={user} password={password} port={port}" 
                                                                      -lco SCHEMA={schema_dest}   
                                                                      -nln gic_geo_role_eval_cleaned_pc_adm_da 
                                                                      -nlt POINT 
                                                                      gic_geo_role_eval_cleaned_pc_adm_da 
                                                                      ') ,
                  'building_footprints_open_data' =  glue::glue('ogr2ogr -progress 
                                                                 -overwrite                  
                                                                --config PG_USE_COPY YES 
                                                                "PG:host={host_dest} dbname={dbname} user={user} password={password} port={port_dest}" 
                                                                "PG:host={host_prod} dbname={dbname} user={user} password={password} port={port}" 
                                                                -lco SCHEMA={schema_dest}    
                                                                -lco GEOMETRY_NAME=geom 
                                                                -nln building_footprints_open_data 
                                                                -nlt MULTIPOLYGON 
                                                                building_footprints_open_data'),
                  'cadastres'= glue::glue('ogr2ogr -progress 
                                          -overwrite 
                                           --config PG_USE_COPY YES   
                                          "PG:host={host_dest} dbname={dbname} user={user} password={password} port={port_dest}" 
                                          "PG:host={host_prod} dbname={dbname} user={user} password={password} port={port}" 
                                          -lco SCHEMA={schema_dest}   
                                          -lco GEOMETRY_NAME=geom 
                                          -nln cadastres 
                                          -nlt MULTIPOLYGON 
                                          cadastres'),
                  'gic_geo_pc_no_dups'= glue::glue('ogr2ogr -progress 
                                           -overwrite 
                                          --config PG_USE_COPY YES   
                                          "PG:host={host_dest} dbname={dbname} user={user} password={password} port={port_dest}" 
                                          "PG:host={host_prod} dbname={dbname} user={user} password={password} port={port}" 
                                          -lco SCHEMA={schema_dest} 
                                          -lco GEOMETRY_NAME=geom 
                                          -nln gic_geo_pc_no_dups 
                                          -nlt MULTIPOLYGON 
                                          gic_geo_pc_no_dups')
)



# Iterate over the list and run the ogr2ogr command ONLY if the corresponding table (given by list name) does not exist
lapply(seq_along(list_ogr_cmd), function(x){
  
  tbl_name <-  tolower(names(list_ogr_cmd)[[x]])
  tbl_exists <- RPostgres::dbExistsTable(conn_dest, DBI::Id(schema = schema_dest, table=tbl_name))
  
  # Populate DB by uploading tables
  if(!tbl_exists){
    print(glue::glue('Uploading {tbl_name} by running {list_ogr_cmd[[x]]}'))
    system( gsub("[\r\n]", "",list_ogr_cmd[[x]])) # remove line endings
  }else{
    print(glue::glue('Table {tbl_name} already exists'))
  }
})
