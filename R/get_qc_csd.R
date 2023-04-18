
library(magrittr)
library(mapview)
library(dplyr)

 
#' Download stats can census subdivision shp files isntead of the usual cartographic adm boundary files
#'
#' @return
#' @export
#'
#' @examples
download_csd_wrappe <- function(){
  
  # Get census subdivision - ~ agglomerations within the cma
  url_download <- 'https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/lcsd000a22a_e.zip'
  
  dir_dl <- tempdir(check = T)
  temp_file <- tempfile(tmpdir = dir_dl)
  download.file(url_download, temp_file)
  
  utils::unzip(temp_file, exdir = dir_dl, overwrite = T)
  unlink(temp_file)
  
  # Read in the shp file into R + reproject and make sure geometry is valid
  shp_csd <- sf::st_read(file.path(dir_dl, paste0(tools::file_path_sans_ext(basename(url_download)), '.shp')))
  shp_csd %<>% sf::st_transform(crs=4326)
  shp_csd %<>% sf::st_make_valid()
  shp_csd %<>% filter(PRUID == '24')
  
  # Rename the geometry
  shp_csd %<>% rename(geom=geometry)
  
  unlink(dir_dl, recursive = T)
  
  return (shp_csd)
  
}


download_csd <- function(dir_cache = here::here('cache')){
 
  if(!dir.exists(dir_cache)) dir.create(dir_cache)
  
  ben.R.utils::cache_wrapper('csd_qc',
                             download_csd_wrappe, 
                             path_cache_dir = dir_cache,
                             is_spatial  =T)
  
}




#' Upload the table to postgis + create the spatial index on the geom column
#'
#' @param shp 
#' @param conn 
#' @param layer_name 
#'
#' @return
#' @export
#'
#' @examples
write_tbl <- function(shp, conn, layer_name){
  
  # Quick QA
  assertthat::assert_that('geom' %in% colnames(shp))
  
  # Write the tbl to postgis 
  sf::st_write(shp, 
               conn, 
               layer = layer_name, 
               layer_options = c( 'OVERWRITE=YES', "GEOMETRY_NAME='geom'")
  )
  

  # Set the spatial index  
  query_index <- '  
    CREATE INDEX if not exists gic_geo_muni_census_idx 
    ON  public.gic_geo_muni_census
    USING GIST(geom);
  '
  
  RPostgres::dbExecute(conn, query_index)
  
  
}




#' Spatial join the tax dataset on csd and add the 
#'
#' @param conn 
#' @param tax_tbl_name 
#' @param census_tbl_name 
#'
#' @return
#' @export
#'
#' @examples
add_city_tax <- function(conn,
                         tax_tbl_name = 'public.gic_geo_role_eval_cleaned_pc_adm_da',
                         census_tbl_name = 'public.gic_geo_muni_census'){
  
  # Add the new columns to the tax dataset
  query_add_to_tax <- glue::glue('ALTER table {tax_tbl_name} 
                                  ADD COLUMN IF NOT EXISTS arrond_census varchar (255), 
                                  ADD COLUMN IF NOT EXISTS muni_census varchar(255),
                                  ADD COLUMN IF NOT EXISTS reg_adm_census varchar(255);')
  
  RPostgres::dbExecute(conn, query_add_to_tax)
  
  # Spatial join + fill in the 3 new columns
  query_merge <-  glue::glue('    
      WITH transformed as (
        select st_transform(geom, 3347) as geom_transf, "CSDNAME", "CDNAME", "ERNAME"
        from {census_tbl_name}
      ), 
      join_query AS (
        SELECT poly.*, pts.geom, pts.id_provinc 
        FROM {tax_tbl_name} as pts
        JOIN transformed as poly
        ON ST_Contains(poly.geom_transf, pts.geom)
      )
      UPDATE {tax_tbl_name} as m
      SET arrond_census = join_query."CSDNAME",  
          muni_census = join_query."CDNAME", 
          reg_adm_census = join_query."ERNAME"
      FROM join_query
      WHERE m.id_provinc = join_query.id_provinc
    '
  )
  RPostgres::dbExecute(conn, query_merge)
  
  
}


# ------------- Main -------


# DB params 

## localhost

conn_local_host <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= Sys.getenv("POSTGRES_DBNAME"),
  host = 'localhost',
  user = Sys.getenv("POSTGRES_USER"),
  password =  Sys.getenv("POSTGRES_PASSWORD"),
  port= Sys.getenv("POSTGRES_PORT")
)



## prod

conn_prod <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= Sys.getenv("POSTGRES_DBNAME"),
  host = Sys.getenv('POSTGRES_HOST_PROD'),
  user = Sys.getenv("POSTGRES_USER"),
  password =  Sys.getenv("POSTGRES_PASSWORD"),
  port= Sys.getenv("POSTGRES_PORT")
)



# download csd polygons
shp_csd <- download_csd() 


# write tbl 
write_tbl(shp_csd, 
          conn_local_host, 
          layer_name = "gic_geo_muni_census"
)
## prod 
write_tbl(shp_csd, 
          conn_prod, 
          layer_name = "gic_geo_muni_census"
)

# Spatial join on csd
add_city_tax(conn_local_host)
add_city_tax(conn_prod)


