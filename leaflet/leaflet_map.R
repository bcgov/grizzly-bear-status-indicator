## --
## LEAFLET
## --

# Prep - colour palettes
factpal <- colorFactor(palette = 'magma', popunits$STATUS) # Assign scheme -- to be replaced with SEO default

# Generate leaflet map showing conservation status of grizzly population units
# Note: All years included
grizzmap <- leaflet() %>%
  addProviderTiles(providers$Stamen.TerrainBackground) %>%
  #addMarkers(data = popunits_simple, lng = ~ X, lat = ~Y, popup = popunits_simple$DISPLAY_NAME) %>%
  addLegend("bottomright", pal = factpal, values = popunits_simple$STATUS,
            title = "Conservation Status",
            opacity = 1) %>%
  addPolygons(data = popunits_simple,
              stroke = T, weight = 1, color = "white", # Add border to polygons
              fillOpacity = 0.4, # Polygon fill
              fillColor = ~factpal(popunits_simple$STATUS),
              highlight = highlightOptions( # Highlight interaction for mouse hover
                weight = 3,
                color = "yellow",
                bringToFront = T))
grizzmap # View leaflet

# Not finished:
#  addLabelOnlyMarkers(data = popunits_2012,
#                      label = as.character(popunits_2012$POPULATION_NAME),
#                      labelOptions = leaflet::labelOptions(
#                        noHide = F,
#                        direction = 'top',
#                        textOnly = T,
#                        opacity = 1))

