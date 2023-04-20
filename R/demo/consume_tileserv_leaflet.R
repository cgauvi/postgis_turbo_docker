 

library(leaflet)
library(magrittr)
library(htmltools)
library(htmlwidgets)

m <- leaflet() %>% 
  setView(lng = -71.0589, lat = 46.5, zoom = 10)

m %<>% addTiles(urlTemplate = "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png", group ='basemap')

 
vector_tile_plugin <- htmltools::htmlDependency(
  name = "leaflet.vectorgrid", 
  version = "1.3.0",
  src = ".",
  head = '<script src="https://unpkg.com/leaflet.vectorgrid@latest/dist/Leaflet.VectorGrid.bundled.js"></script>',
  all_files = F
)
 
register_map_plugin <- function(map, plugin) {
  map$dependencies <- c(map$dependencies, list(plugin))
  map
}

m %<>% register_map_plugin(vector_tile_plugin)

m

m %<>%  addLayersControl(
  overlayGroups = c("basemap" ,"overlay"),
  options = layersControlOptions(collapsed = FALSE)
)

m

m %<>% htmlwidgets::onRender('

    function(el, x) {
    
      var map = this;
      
      var openmaptilesUrl = "http://localhost:5055/postgisftw.mvt_from_buildings/{z}/{x}/{y}.pbf";

		  var openmaptilesVectorTileOptions = {
  		 vectorTileLayerStyles: {
        // A plain set of L.Path options.
        default: {
            fillColor: "#9bc2c4",
            fillOpacity: 1,
            fill: true
          }
		    }
		  };


		  var openmaptilesPbfLayer = L.vectorGrid.protobuf(openmaptilesUrl, openmaptilesVectorTileOptions).addTo(map);

      const newOverlay = Object.assign({}, overlay, {"vector tiles":openmaptilesPbfLayer});
  		L.control.layers(basemap, newOverlay).addTo(map);
      
    }')

m



# Output html file for debugging in the console
output_dir <- here::here('output')
if(!dir.exists(output_dir)) dir.create(output_dir)
html_path <- file.path(output_dir, 'leaflet_debug.html')
if(file.exists(html_path)) unlink(html_path)
htmlwidgets::saveWidget(widget = m, file = html_path )
