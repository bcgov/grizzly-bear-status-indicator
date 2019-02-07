## --------
## LEAFLET
## --------

# Create custom icons
tree <- makeAwesomeIcon(
  icon = 'tree-conifer', library = 'glyphicon', markerColor = 'black',
  iconColor = 'white')

# Prep - colour palettes
factpal <- colorFactor(palette = 'magma', grizzdata_full$status) # Assign scheme

## ------
## POPUPS
## -------
grizz_plotlist <- readRDS(here("out/grizz_plotlist.rds"))[grizzdata_full$population_name]
popups <-  popupGraph(grizz_plotlist, type = "svg", width = 500,
                      height = 300)
popup_options <-  popupOptions(maxWidth = "100%", autoPan = TRUE,
                               keepInView = TRUE,
                               closeOnClick = TRUE,
                               autoPanPaddingTopLeft = c(120, 10),
                               autoPanPaddingBottomRight = c(120,10))
require(htmltools)
plotlabs <- sprintf(
  "<strong>%s</strong>",
  tools::toTitleCase(tolower(grizzdata_full$population_name))
) %>% lapply(htmltools::HTML)

## ------
## SETUP
## ------

grizzmap <- leaflet(grizzdata_full, width = "900px", height = "500px") %>%   # generate leaflet map
  addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain") %>%
  addTiles(group = "OSM (Default") %>%
  add_bc_home_button() %>%
  set_bc_view() %>%
  set_bc_view_on_close() %>% # re-centre map on popup close
  addLegend("bottomright", pal = factpal, values = grizzdata_full$status,
            title = "Population Status",
            opacity = 1) %>%
  addPolygons(stroke = T, weight = 1, color = "black", # Add border to polygons
              fillOpacity = 0.4, # Polygon fill
              fillColor = ~factpal(grizzdata_full$status),
              popup = popups,
              popupOptions = popup_options,
              label = plotlabs,
              labelOptions = labelOptions(direction = "auto", textsize = "12px"),
              highlight = highlightOptions( # Highlight interaction for mouse hover
                weight = 4,
                color = "yellow",
                bringToFront = T)) %>%
  addLayersControl(
    baseGroups = c("Terrain", "OSM (Default"))
grizzmap # View leaflet
