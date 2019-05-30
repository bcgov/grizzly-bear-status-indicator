# Define server logic required to draw the leaflet map
server <- function(input, output, session) {

  output$grizzmap <- renderLeaflet({
    grizzmap <- leaflet(grizzdata_full, width = "900px", height = "900px") %>%   # generate leaflet map
      addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain") %>% # or providers$Stamen.TerrainBackground
      addTiles(group = "OpenStreetMap (Default") %>%
      add_bc_home_button() %>%
      set_bc_view() %>%
      addLegend("bottomright", pal = palette1, values = grizzdata_full$rankcode,
                title = "Conservation Status",
                opacity = 1) %>%
      addPolygons(stroke = T, weight = 1, color = "black", # Add border to polygons
                  fillOpacity = 0.4, # Polygon fill
                  fillColor = ~palette1(grizzdata_full$rankcode),
                  popup = popups,
                  popupOptions = popup_options,
                  group = "Conservation Rank",
                  label = plotlabs,
                  labelOptions = labelOptions(direction = "auto", textsize = "12px"),
                  highlight = highlightOptions( # Highlight interaction for mouse hover
                    weight = 3,
                    color = "yellow",
                    bringToFront = T)) %>%
      addPolygons(stroke = T, weight = 1, color = "black",
                  fillOpacity = 0.2,
                  fillColor = ~palette2(grizzdata_full$adults),
                  group = "Population Estimate",
                  label = plotlabs,
                  labelOptions = labelOptions(direction = "auto", textsize = "12px"),
                  highlight = highlightOptions( # Highlight interaction for mouse hover
                    weight = 3,
                    color = "yellow",
                    bringToFront = T)) %>%
      addPolygons(stroke = T, weight = 1, color = "black", # Add border to polygons
                  fillOpacity = 0.2, # Polygon fill
                  fillColor = ~palette3(grizzdata_full$threat_class),
                  group = "Overall Threat Class",
                  label = plotlabs,
                  labelOptions = labelOptions(direction = "auto", textsize = "12px"),
                  highlight = highlightOptions( # Highlight interaction for mouse hover
                    weight = 3,
                    color = "yellow",
                    bringToFront = T)) %>%
      addLayersControl(
        baseGroups = c("Conservation Status", "Population Estimate", "Overall Threat Class"),
        overlayGroups = c("Terrain", "OpenStreetMap"))
  })
  leafletOutput('grizzmap', width = "100%")
}

# Run the application
runApp(shinyApp(ui = ui, server = server), launch.browser = TRUE)

# Run condensed version of ui (no header)
shinyApp(ui = ui_embedded, server = server)
