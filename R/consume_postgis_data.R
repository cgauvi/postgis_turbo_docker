

library(magrittr)
library(mapview)


# Buildings
url <- 'http://localhost:5054/collections/postgisftw.building_footprints_open_data_proj/items.json?limit=1000'
shp_buildings <- sf::st_read(url)
nrow(shp_buildings)


# Tax data 
url <- 'http://localhost:5054/collections/postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_proj/items.json?limit=500'
shp_tax <- sf::st_read(url)
nrow(shp_tax)

mapview(shp_buildings,color='green') + 
  mapview(shp_tax)
