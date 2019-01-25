## --
## LEAFLET
## --

# Prep - colour palettes
factpal <- colorFactor(palette = 'magma', popunits$STATUS) # Assign scheme -- to be replaced with SEO default

# Generate leaflet map showing conservation status of grizzly population units
# Note: All years included
# Generate leaflet map showing conservation status of grizzly population units
grizzmap <- leaflet() %>%
  addProviderTiles(providers$Stamen.Terrain) %>%
  addLegend("bottomright", pal = factpal, values = popunits_xy$status,
            title = "Population Status",
            opacity = 1) %>%
  addPolygons(data = popunits_xy,
              stroke = T, weight = 1, color = "white", # Add border to polygons
              fillOpacity = 0.4, # Polygon fill
              fillColor = ~factpal(popunits_xy$status),
              highlight = highlightOptions( # Highlight interaction for mouse hover
                weight = 3,
                color = "yellow",
                bringToFront = T)) %>%
  addMarkers(data = popunits_xy, lng = ~lng, lat = ~lat,
             label = popunits_xy$population_name, icon = pawicon,
             labelOptions = labelOptions(noHide = F, textOnly = F))

grizzmap # View leaflet

# Create custom icons - will need to be hosted on the web
xicon <- makeIcon("/Users/JGALLOWA/AppData/Local/Temp/x-square.svg",
                  iconWidth = 24,
                  iconHeight = 30)
circleicon <- makeIcon("/Users/JGALLOWA/AppData/Local/Temp/circle.svg",
                       iconWidth = 10,
                       iconHeight = 10)

#   addLabelOnlyMarkers(data = grizzxy,
#                      lng = ~lng, lat = ~lat,
#                      label = as.character(grizzxy$DISPLAY_NAME),
#                      labelOptions = leaflet::labelOptions(
#                        noHide = F,
#                        direction = "top",
#                        opacity = 1
#                       )
#                     )


