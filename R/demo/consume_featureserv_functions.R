
library(magrittr)
library(mapview)

db <- 'dev'
#db <- 'localhost'

assertthat::assert_that(db %in% c('dev','localhost'))
conn_str <- ifelse(db == 'dev', 'training-bi-ia.ssq.local:9002', 'localhost:5054')

fun <- 'postgisftw.to_tsquery_partial'

partial_str_demo <- 'Brock'


# Get addresses in the tax assessment dataset (role) that match a given partial string 
url <- glue::glue('http://{conn_str}/functions/{fun}/items.json?partialstr={partial_str_demo}&limit=100')
shp_partial_role <- sf::st_read(URLencode(url))
nrow(shp_partial_role)


mapview::mapview(shp_partial_role)

