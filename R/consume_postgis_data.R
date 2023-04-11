

library(magrittr)
library(mapview)


# Buildings
url <- 'http://localhost:9001/collections/postgisftw.building_footprints_open_data_proj/items.json'
shp_buildings <- sf::st_read(url)



# Tax data 
url <- 'http://localhost:9001/collections/postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_proj/items.json'
shp_tax <- sf::st_read(url)

mapview(shp_buildings) + 
  mapview(shp_tax)
