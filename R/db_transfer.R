### setup #### 

# db parameters
dbname= Sys.getenv("POSTGRES_DBNAME")
host_prod = Sys.getenv('POSTGRES_HOST_PROD')
user = Sys.getenv("POSTGRES_USER")
password = Sys.getenv("POSTGRES_PASSWORD")
port= Sys.getenv("POSTGRES_PORT")

# Connect as admin
conn_admin_prod <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= dbname,
  host = host_prod,
  user = user,
  password = password,
  port= port
)

# shp_role <- sf::st_read(conn_admin_prod,
#                     query='select * from gic_geo_role_eval_cleaned_pc_adm_da')
# 
# 
# if(dir.exists(here::here('data'))) dir.create(here::here('data'))
# sf::st_write(shp_role, here::here('data', 'gic_geo_role_eval_cleaned_pc_adm_da_v2'))

conn_local_host <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= dbname,
  host = 'localhost',
  user = user,
  password = password,
  port= port
)

#### ogr2ogr commands to load data  ### 
# Copy  from remote 'prod' db to local host
list_ogr_cmd <- c('gic_geo_role_eval_cleaned_pc_adm_da' = glue::glue( 'ogr2ogr -progress  --config PG_USE_COPY YES  "PG:host=localhost dbname={dbname} user={user} password={password} port={port}" "PG:host={host_prod} dbname={dbname} user={user} password={password} port={port}" -lco SCHEMA=public    -nln gic_geo_role_eval_cleaned_pc_adm_da gic_geo_role_eval_cleaned_pc_adm_da_proj -overwrite') 
                  )




lapply(seq_along(list_ogr_cmd), function(x){
  
  tbl_name <-  tolower(names(list_ogr_cmd)[[x]])
  
  # Populate DB by uploading tables
  if(!RPostgres::dbExistsTable(conn_local_host, tbl_name)){
    print(glue::glue('Uploading {tbl_name} by running {list_ogr_cmd[[x]]}'))
    system(list_ogr_cmd[[x]])
  }else{
    print(glue::glue('Table {tbl_name} already exists'))
  }
})
