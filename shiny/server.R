# Define server logic required to draw the leaflet map
server <- function(input, output, session) {

  output$grizzmap <- renderLeaflet({
    grizzmap <- leaflet(grizzdata_full) %>%   # generate leaflet map
      addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain") %>%
      addTiles(group = "OSM (Default") %>%
      add_bc_home_button() %>%
      set_bc_view() %>%
      addLegend("bottomright", pal = factpal, values = grizzdata_full$status,
                title = "Conservation Status", opacity = 1) %>%
      addLegend("bottomleft", pal = poppal, values = grizzdata_full$pop_estimate,
                title = "Population Estimate", opacity = 1) %>%
      addPolygons(stroke = T, weight = 1, color = "black", # Add border to polygons
                  fillOpacity = 0.4, # Polygon fill
                  fillColor = ~factpal(grizzdata_full$status),
                  group = "Mortality",
                  popup = popups,
                  popupOptions = popup_options,
                  label = plotlabs,
                  labelOptions = labelOptions(direction = "auto", textsize = "12px"),
                  highlight = highlightOptions( # Highlight interaction for mouse hover
                    weight = 3,
                    color = "yellow",
                    bringToFront = T)) %>%
      addPolygons(stroke = T, weight = 1, color = "black",
                  fillOpacity = 0.4,
                  fillColor = ~poppal(grizzdata_full$pop_estimate),
                  group = "Population Estimate",
                  label = plotlabs,
                  popup = popups,
                  popupOptions = popup_options,
                  highlight = highlightOptions( # Highlight interaction for mouse hover
                    weight = 3,
                    color = "yellow",
                    bringToFront = T)) %>%
      addLayersControl(
        baseGroups = c("Terrain", "OSM (Default"),
        overlayGroups = c("Conservation Status", "Population Estimate")
        )
  })
  leafletOutput('grizzmap', width = "100%")
}

# Run the application
runApp(shinyApp(ui = ui, server = server), launch.browser = TRUE)

# Run condensed version of ui (no header)
shinyApp(ui = ui_embedded, server = server)
