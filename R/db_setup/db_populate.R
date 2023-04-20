### setup #### 

readRenviron ('../.Renviron')

DEST_DB <- 'dev'
RUN_FEAT_SERV=T
RUN_TILE_SERV=F


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

# Feature serv
if(RUN_FEAT_SERV){
  
  lapply(list_sql_commands_feature_serv , function(x){
    
    cmd <- paste0(readLines(x), sep='', collapse = ' ')

    print(glue::glue("Running {cmd}..."))

    RPostgres::dbExecute(
        conn = conn_admin,
        statement =  gsub("[\r\n\t]", " ", glue::glue(cmd))
    )


  })
  
  print('Successfully ran all feature serv queries')
}
 


# Feature serv
if(RUN_TILE_SERV){
  
  lapply(list_sql_commands_tile_serv , function(x){
    
    cmd <- paste0(readLines(x), sep='', collapse = ' ')
    
    print(glue::glue("Running {cmd}..."))
    
    RPostgres::dbExecute(
      conn = conn_admin,
      statement =  gsub("[\r\n\t]", " ", glue::glue(cmd))
    )
    
    
  })
  
  print('Successfully ran all tile serv queries')
}


# Comments
cmd <- paste0(readLines( here::here('../sql/comments.sql')), sep='', collapse = ' ')
list_cmds <- strsplit(cmd, split = '-- #', fixed = T)

lapply(seq_along(list_cmds[[1]]), function(x){
  print(glue::glue("Running {list_cmds[[1]][[x]]}..."))
  
  res <- RPostgres::dbExecute(
    conn = conn_admin,
    statement =  gsub("[\r\n\t]", " ", list_cmds[[1]][[x]])
  )
  
  
})
