## --------
## LEAFLET
## --------
library(bcmaps)
available_layers()

# Create custom icons
tree <- makeAwesomeIcon(
  icon = 'tree-conifer', library = 'glyphicon', markerColor = 'black',
  iconColor = 'white')

# Prep - colour palettes
palette1 <- colorFactor(palette = 'viridis', grizzdata_full$rankcode,
                        reverse = TRUE, na.color = "#808080")
palette2 <- colorFactor(palette = 'viridis', grizzdata_full$adults,
                        reverse = TRUE, na.color = "#808080")

## ------
## POPUPS
## -------
grizz_plotlist <- readRDS(here("out/grizz_plotlist.rds"))[grizzdata_full$gbpu_name]
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
  tools::toTitleCase(tolower(grizzdata_full$gbpu_name))
) %>% lapply(htmltools::HTML)

## ------
## LEAFLET MAP -- POPULATION AND CONSERVATION STATUS
## ------
grizzmap <- leaflet(grizzdata_full, width = "900px", height = "500px") %>%   # generate leaflet map
  addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain") %>%
  addTiles(group = "OSM (Default") %>%
  add_bc_home_button() %>%
  set_bc_view() %>%
  set_bc_view_on_close() %>% # re-centre map on popup close - do we want this?
  addLegend("bottomright", pal = palette1, values = grizzdata_full$rankcode,
            title = "Conservation Status",
            opacity = 1) %>%
  addPolygons(stroke = T, weight = 1, color = "black", # Add border to polygons
              fillOpacity = 0.4, # Polygon fill
              fillColor = ~palette1(grizzdata_full$rankcode),
              #popup = popups,
              #popupOptions = popup_options,
              group = "Conservation Rank",
              label = plotlabs,
              labelOptions = labelOptions(direction = "auto", textsize = "12px"),
              highlight = highlightOptions( # Highlight interaction for mouse hover
                weight = 3,
                color = "yellow",
                bringToFront = T)) %>%
  addPolygons(stroke = T, weight = 1, color = "black",
              fillOpacity = 0.4,
              fillColor = ~palette2(grizzdata_full$adults),
              group = "Population Estimate",
              label = plotlabs,
              labelOptions = labelOptions(direction = "auto", textsize = "12px"),
              highlight = highlightOptions( # Highlight interaction for mouse hover
                weight = 3,
                color = "yellow",
                bringToFront = T)) %>%
  addLayersControl(
    baseGroups = c("Terrain", "OSM (Default"),
    overlayGroups = c("Conservation Status", "Population Estimate"))
grizzmap # View leaflet

## ------------------------------
## LEAFLET MAP -- THREAT MAPPING
## ------------------------------
tpalette1 <- colorFactor(palette = 'viridis', grizzdata_full$transportationcalc,
                         reverse = TRUE, na.color = "#808080")
tpalette2 <- colorFactor(palette = 'viridis', grizzdata_full$energycalc,
                         reverse = TRUE, na.color = "#808080")
tpalette3 <- colorFactor(palette = 'viridis', grizzdata_full$humanintrusioncalc,
                         reverse = TRUE, na.color = "#808080")

# Generate leaflet map
threatmap <- leaflet(grizzdata_full, width = "900px", height = "500px") %>%
  addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain") %>%
  addTiles(group = "OSM (Default") %>%
  add_bc_home_button() %>%
  set_bc_view() %>%
  set_bc_view_on_close() %>% # re-centre map on popup close
  #addLegend("bottomright", pal = tpalette1, values = grizzdata_full$transportationcalc,
            #title = "Transportation Threats",
            #opacity = 1) %>%
  addPolygons(stroke = T, weight = 1, color = "black", # Add border to polygons
              fillOpacity = 0.4, # Polygon fill
              fillColor = ~tpalette1(grizzdata_full$transportationcalc),
              #popup = popups,
              #popupOptions = popup_options,
              group = "Transportation Threat",
              label = plotlabs,
              labelOptions = labelOptions(direction = "auto", textsize = "12px"),
              highlight = highlightOptions( # Highlight interaction for mouse hover
                weight = 3,
                color = "yellow",
                bringToFront = T)) %>%
  addPolygons(stroke = T, weight = 1, color = "black",
              fillOpacity = 0.4,
              fillColor = ~tpalette2(grizzdata_full$energycalc),
              group = "Energy Threat",
              label = plotlabs,
              labelOptions = labelOptions(direction = "auto", textsize = "12px"),
              highlight = highlightOptions(
                weight = 3,
                color = "yellow",
                bringToFront = T)) %>%
  addPolygons(stroke = T, weight = 1, color = "black",
              fillOpacity = 0.4,
              fillColor = ~tpalette3(grizzdata_full$humanintrusioncalc),
              group = "Human Intrusion Threat",
              label = plotlabs,
              labelOptions = labelOptions(direction = "auto", textsize = "12px"),
              highlight = highlightOptions(
                weight = 3,
                color = "yellow",
                bringToFront = T)) %>%
  addLayersControl(
    baseGroups = c("Terrain", "OSM (Default"),
    overlayGroups = c("Transportation Threat", "Energy Threat", "Human Intrusion Threat"))
threatmap # View leaflet
