# Define server logic required to draw the leaflet map
server <- function(input, output, session) {

  output$grizzmap <- renderLeaflet({
    grizzmap <- leaflet() %>%     # generate leaflet
      addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain") %>%
      addTiles(group = "OSM (Default") %>%
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
      addMarkers(data = grizzdata, lng = ~lng, lat = ~lat,
                 label = grizzdata$population_name, icon = glyphtree,
                 labelOptions = labelOptions(noHide = F, textOnly = F))
  })
}

# Run the application
shinyApp(ui = ui, server = server)

