### setup #### 

readRenviron ('../.Renviron')

DEST_DB <- 'dev'
RUN_FEAT_SERV=T
RUN_TILE_SERV=T
MAX_ATTEMPTS <- 10

assertthat::assert_that(DEST_DB %in% c('dev', 'localhost'))

# db parameters
dbname= Sys.getenv("POSTGRES_DBNAME")
user = Sys.getenv("POSTGRES_USER")
password = Sys.getenv("POSTGRES_PASSWORD")
host <- ifelse(DEST_DB == 'dev', Sys.getenv('POSTGRES_HOST_DEV'), 'localhost')
port <- ifelse(DEST_DB == 'dev', Sys.getenv('POSTGRES_PORT_DEV'), Sys.getenv('POSTGRES_PORT') )


# Connect as admin
conn_admin <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= dbname,
  host = host,
  user = user,
  password = password,
  port= port
)
 
 

#### tbl modification / sql commands for mvt  ### 

# Apply all relevant sql commands in order
list_sql_commands_feature_serv <- c(
  here::here('../sql/ts/add_city_name_new_tbl.sql'),
  here::here('../sql/ts/create_ts_address.sql'),
  here::here('../sql/ts/address_query_fcts.sql')
)

assertthat::assert_that(all(sapply(list_sql_commands_feature_serv, file.exists)))

list_sql_commands_tile_serv <- c(
  here::here('../sql/mvt_buildings/create_agg_geohash.sql'),
  here::here('../sql/mvt_buildings/mvt_from_buildings.sql'),
  here::here('../sql/mvt_buildings/mvt_geom_from_buildings.sql'),
  #
  #
  here::here('../sql/mvt_tax/create_proj_rnd_tax.sql'),
  here::here('../sql/mvt_tax/mvt_geom_from_tax.sql'),
  here::here('../sql/mvt_tax/mvt_from_tax.sql')
)

assertthat::assert_that(all(sapply(list_sql_commands_tile_serv, file.exists)))


run_sql_wait_exec <- function(cmd){
  
  r <- NULL
  attempt <- 1
  while( is.null(r) && attempt <= MAX_ATTEMPTS ) {
    attempt <- attempt + 1
    r <-    RPostgres::dbExecute(
        conn = conn_admin,
        statement =  glue::glue(cmd) 
    )

  }
  
  return(r)
  
}

 
run_list_cmds <- function(list_sql_files) {
  
  lapply(list_sql_files, function(x){
    
    cmd <- paste(readLines(x),   collapse = '\n')
    list_cmds <- strsplit(cmd, split = '-- #', fixed = T)
    
    lapply(seq_along(list_cmds[[1]]), function(x){
      print(glue::glue("Running {list_cmds[[1]][[x]]}..."))
      run_sql_wait_exec(gsub("[\t]", " ", glue::glue(list_cmds[[1]][[x]])))
    })
    
  })
  
}
 

if(RUN_FEAT_SERV) {
  run_list_cmds(list_sql_commands_feature_serv)
  print('Successfully ran all feature serv queries')
}
 
  

if(RUN_TILE_SERV) {
  run_list_cmds(list_sql_commands_tile_serv)
  print('Successfully ran all tile serv queries')
}

 


# Comments
list_cmd_comments <- c( here::here('../sql/comments.sql') )
run_list_cmds(list_cmd_comments)
print('Successfully ran all comments queries')