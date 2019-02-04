##**************
## LEAFLET
##**************

# Create custom icons
tree <- makeAwesomeIcon(
  icon = 'tree-conifer', library = 'glyphicon', markerColor = 'black',
  iconColor = 'white')

# Prep - colour palettes
factpal <- colorFactor(palette = 'magma', popunits_xy$status) # Assign scheme

# Popups
grizz_popup <- mutate(popup = )


#plot_list <- readr::write_rds(plot_list, "tmp/plotlist.rds")

##********
## SETUP
##********
grizzmap <- leaflet() %>%   # generate leaflet map
  addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain") %>%
  addTiles(group = "OSM (Default") %>%
  add_bc_home_button() %>%
  set_bc_view_on_close() %>% # re-centre map on popup close
  addLegend("bottomright", pal = factpal, values = grizzdata$status,
            title = "Population Status",
            opacity = 1) %>%
  addPolygons(data = grizzdata,
              stroke = T, weight = 1, color = "black", # Add border to polygons
              fillOpacity = 0.4, # Polygon fill
              fillColor = ~factpal(grizzdata$status),
              highlight = highlightOptions( # Highlight interaction for mouse hover
                weight = 4,
                color = "yellow",
                bringToFront = T)) %>%
  addLayersControl(
    baseGroups = c("Terrain", "OSM (Default")) %>%
  addMarkers(data = grizzdata, group = "Population Unit",lng = ~lng, lat = ~lat,
             label = ~population_name, icon = tree,
             labelOptions = labelOptions(noHide = F, textOnly = F, sticky = F))
grizzmap # View leaflet

