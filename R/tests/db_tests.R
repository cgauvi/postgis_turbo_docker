
# R script to test out permissions & access to DB
# Requires running the tbl_upload script first and populating with at elast gic_geo_muni in public schema
DEST_DB <- 'dev'
assertthat::assert_that(db %in% c('dev','localhost'))

host <- ifelse(DEST_DB == 'dev', Sys.getenv('POSTGRES_HOST_DEV'), 'localhost')
port_dest <- ifelse(DEST_DB == 'dev', Sys.getenv('POSTGRES_PORT_DEV'), Sys.getenv('POSTGRES_PORT') )


# --- Connect as read only user  ---

conn_ro <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname=Sys.getenv("POSTGRES_DBNAME"),
  host = host,
  user = Sys.getenv("POSTGRES_USER_RO"),
  password = Sys.getenv("POSTGRES_PASSWORD_RO"),
  port= port_dest
)

# Should fail: RO can read SELECT from public
testthat::expect_no_error({
  tbl_query_public <- RPostgres::dbGetQuery(
    conn = conn_ro,
    statement = glue::glue(
      "SELECT * from spatial_ref_sys  "
    )
  )
})


testthat::expect_no_error({
  tbl_query_public <- RPostgres::dbGetQuery(
    conn = conn_ro,
    statement = glue::glue(
      "SELECT postgis_typmod_srid(4326)  "
    )
  )
})




# Should succeed - RO can read from postgisftw
testthat::expect_no_error({
  fun_query <- RPostgres::dbGetQuery(
    conn = conn_ro,
    statement = glue::glue(
      "SELECT postgisftw.to_tsquery_partial('beach') "
    )
  )
}
)


testthat::expect_no_error({
  fun_query <- RPostgres::dbGetQuery(
    conn = conn_ro,
    statement = glue::glue(
      "SELECT postgis_full_version();"
    )
  )
}
)

  

# ------ Admin sanity check ----- 

conn_admin <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= Sys.getenv("POSTGRES_DBNAME"),
  host = 'localhost',
  user = Sys.getenv("POSTGRES_USER"),
  password = Sys.getenv("POSTGRES_PASSWORD"),
  port= Sys.getenv("POSTGRES_PORT")
)

# Superuser can read from .. 

# Tables 
testthat::expect_no_error({
tbl_query <- RPostgres::dbGetQuery(
  conn = conn_admin,
  statement = glue::glue(
    "SELECT mus_co_geo, ogc_fid from public.gic_geo_muni "
  )
)
})

# Functions 
testthat::expect_no_error({
fun_query <- RPostgres::dbGetQuery(
  conn = conn_admin,
  statement = glue::glue(
    "SELECT postgisftw.to_tsquery_partial('beach') "
  )
)
})

## Can create new tables
testthat::expect_no_error({
  fun_query <- RPostgres::dbExecute(
    conn = conn_admin,
    statement = glue::glue(
      "CREATE TABLE IF NOT EXISTS postgisftw.s2 AS
      (
         select * from spatial_ref_sys limit 2
      );
      "
    )
  )
})   

## Can create new tables
testthat::expect_no_error({
  fun_query <- RPostgres::dbExecute(
    conn = conn_admin,
    statement = glue::glue(
      "CREATE TABLE IF NOT EXISTS public.s2 AS
      (
         select * from spatial_ref_sys limit 2
      );
      "
    )
  )
})   
#--- RO can access newly created tables in postgisftw ----
  
testthat::expect_no_error({
  tbl_query_postgisftw <- RPostgres::dbGetQuery(
    conn = conn_ro,
    statement = glue::glue(
      "SELECT * from postgisftw.s2  "
    )
  )
})



# -- RO cannot create tables 

testthat::expect_error({
  fun_query <- RPostgres::dbExecute(
    conn = conn_ro,
    statement = glue::glue(
      "CREATE TABLE IF NOT EXISTS postgisftw.s3 AS
      (
     select * from spatial_ref_sys limit 2
      );
      "
    )
  )
})   


testthat::expect_error({
  fun_query <- RPostgres::dbExecute(
    conn = conn_ro,
    statement = glue::glue(
      "CREATE TABLE IF NOT EXISTS public.s3 AS
      (
        select * from spatial_ref_sys limit 2
      );
      "
    )
  )
})   

