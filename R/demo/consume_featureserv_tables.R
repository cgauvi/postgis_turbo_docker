

library(magrittr)
library(mapview)

db <- 'dev'
#db <- 'localhost'

assertthat::assert_that(db %in% c('dev','localhost'))
conn_str <- ifelse(db == 'dev', 'training-bi-ia.ssq.local:9002', 'localhost:5054')

tbl <- 'postgisftw.building_footprints_open_data'
#tbl <- 'postgisftw.building_footprints_open_data_proj'


#---- Try to read in all at once ----


# Buildings
url <- glue::glue('http://{conn_str}/collections/{tbl}/items.json?limit=10000&filter=gid_origin < 100')
shp_buildings <- sf::st_read(URLencode(url))
nrow(shp_buildings)

# Postal codes 
url <- glue::glue('http://{conn_str}/collections/postgisftw.gic_geo_pc_no_dups/items.json?limit=500000')
shp_postal_codes <- sf::st_read(URLencode(url))
nrow(shp_postal_codes)

# Tax data 
url <- glue::glue('http://{conn_str}/collections/{tbl}/items.json?limit=500')
shp_tax <- sf::st_read(url)
nrow(shp_tax)

mapview(shp_buildings,color='green') + 
  mapview(shp_tax)



#---- Iterator ----

#' Iterate over simple features and return a final (large) sf object
#' 
#' See http://training-bi-ia.ssq.local:9002 for more details on the actual object being downloaded
#'
#' @param tbl 
#' @param col_to_iter 
#' @param batch_size 
#' @param base_url 
#'
#' @return sf object
#' @export
#'
#' @examples 
#' \dontrun{
#' shp_postal_codes <- feature_iterator('postgisftw.gic_geo_pc_no_dups', batch_size=5000)
#' }
feature_iterator <- function(tbl, 
                             col_to_iter = 'ogc_fid',
                             batch_size=1000,
                             base_url = 'http://training-bi-ia.ssq.local:9002'){
  # No scientific notation
  options(scipen=999)
  
  
  assertthat::assert_that(batch_size > 1)
  batch_size <- as.integer(batch_size)
  offset <- 1
  
  url <- glue::glue('{base_url}/collections/{tbl}/items.json?limit={batch_size}&filter={col_to_iter} BETWEEN 1 AND {batch_size*offset}')
  shp <- sf::st_read(URLencode(url))
  
  has_data <- nrow(shp) == batch_size
  if(!has_data) warning('Warning! data has less than {batch_size} rows, make sure {col_to_iter} is non-negative integer based or use another column')
  data <- list(shp)
  
  # Iterate over col_to_iter in increments of batch_size
  while(has_data){
    
    offset <- offset+1
    url <- glue::glue('{base_url}/collections/{tbl}/items.json?limit={batch_size}&filter={col_to_iter} BETWEEN {batch_size*(offset-1)+1} AND {batch_size*(offset)}')
    shp <- sf::st_read(URLencode(url))
    
    has_data <- nrow(shp) == batch_size
    data <- rlist::list.append(data, shp)
  }
  
  # Bind the data
  shp_final <- do.call(rbind, data)
   
  
  return(shp_final)
  
}


feature_iterator('postgisftw.gic_geo_pc_no_dups', batch_size=5000)



#---- Compare with reading off the db directly ----
 

readRenviron ('../.Renviron')

conn_ro <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname=Sys.getenv("POSTGRES_DBNAME"),
  host =Sys.getenv('POSTGRES_HOST_DEV'),
  user = Sys.getenv("POSTGRES_USER_RO"),
  password = Sys.getenv("POSTGRES_PASSWORD_RO"),
  port= Sys.getenv("POSTGRES_PORT_DEV")
)

shp_buildings <- sf::st_read(query=glue::glue('select * from {tbl} limit 10'), conn_ro)
