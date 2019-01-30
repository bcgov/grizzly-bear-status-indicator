# This is a Shiny web application.
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# Loading R libraries
Packages <- c("tidyverse", "shiny", "devtools", "bcmaps",
              "ggplot2", "leaflet", "rmapshaper", "viridis",
              "bcdata", "envreportutils","ggspatial", "ggrepel")
lapply(Packages, library, character.only = TRUE)

# Load data
grizzdata <- popunits_xy

tree <- makeAwesomeIcon(  # Make icon
  icon = 'tree-conifer', library = 'glyphicon', markerColor = 'black',
  iconColor = 'white')

# Define UI for grizzly bear leaflet map
ui <- navbarPage(title = div(img(src = "http://www2.gov.bc.ca/assets/gov/home/gov3_bc_logo.png"),
                             "Grizzly Bear Conservation Status in British Columbia"),
                 tabPanel("Interactive Map"),
                 tabPanel("Data Explorer"),
                 mainPanel(leafletOutput(outputId = "grizzmap")),
                 navbarMenu("More",
                            tabPanel("About"),
                            tabPanel("Summary"))
                 )

