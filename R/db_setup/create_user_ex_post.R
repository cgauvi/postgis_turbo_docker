library(glue)

readRenviron ('../.Renviron')

DEST_DB <- 'dev'

assertthat::assert_that(DEST_DB %in% c('dev', 'localhost'))
host_dest <- ifelse(DEST_DB == 'dev', Sys.getenv('POSTGRES_HOST_DEV'), 'localhost')
port_dest <- ifelse(DEST_DB == 'dev', Sys.getenv('POSTGRES_PORT_DEV'), Sys.getenv('POSTGRES_PORT') )

dbname= Sys.getenv("POSTGRES_DBNAME")
host_prod = Sys.getenv('POSTGRES_HOST_PROD')
user = Sys.getenv("POSTGRES_USER")
user_ro=Sys.getenv("POSTGRES_USER_RO")
password = Sys.getenv("POSTGRES_PASSWORD")
port= Sys.getenv("POSTGRES_PORT")

pub_schema='postgisftw'

conn_dest <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= dbname,
  host =  host_dest,
  user = user,
  password = password,
  port= port_dest
)



list_sql <- c(  
                    glue("GRANT CONNECT ON DATABASE {dbname} TO {user_ro};"),
                     glue("GRANT USAGE ON SCHEMA public TO {user_ro};" ),
                     glue("REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC ;"),
                     glue("GRANT SELECT ON TABLE public.spatial_ref_sys TO {user_ro};"),
                     glue("REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC ;"),
                     glue("GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO {user_ro};"),
                     glue("REVOKE ALL ON ALL PROCEDURES IN SCHEMA public FROM PUBLIC ;"),
                     glue( "GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO {user_ro};")
                )

lapply(seq_along(list_sql), function(x){ DBI::dbExecute(conn_dest, list_sql[[x]])})
 
                
list_sql <- c(  
  glue("REVOKE USAGE ON SCHEMA {pub_schema} FROM PUBLIC;"),
  glue("GRANT USAGE ON SCHEMA {pub_schema} TO {user_ro};"),
  glue("REVOKE ALL ON ALL TABLES IN SCHEMA {pub_schema} FROM {user_ro};"),
  glue("GRANT SELECT ON ALL TABLES IN SCHEMA {pub_schema} TO {user_ro};"),
  glue("GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA {pub_schema}  TO {user_ro};"),
  glue("GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA {pub_schema}  TO {user_ro};")
)

lapply(seq_along(list_sql), function(x){ DBI::dbExecute(conn_dest, list_sql[[x]])})


