# Define server logic required to draw the leaflet map
server <- function(input, output, session) {

  output$grizzmap <- renderLeaflet({
    grizzmap <- leaflet(grizzdata_full, width = "900px", height = "500px") %>%   # generate leaflet map
      addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain") %>%
      addTiles(group = "OSM (Default") %>%
      add_bc_home_button() %>%
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
  })
}

# Run the application
shinyApp(ui = ui, server = server)

