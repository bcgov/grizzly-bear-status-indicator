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

# Custom icon from 'www' reference file in shiny
pawicon <- makeIcon("grizzly_paw_icon.png", iconWidth = 24, iconHeight = 24)

# Custom icon from glyphicon
tree <- icon("tree-conifer", lib = "glyphicon")

# Basic UI
ui <- navbarPage(title = div(img(src = "http://www2.gov.bc.ca/assets/gov/home/gov3_bc_logo.png"),
                             "Grizzly Bear Conservation Status in British Columbia"),
                 tabPanel("Interactive Map"),
                 tabPanel("Data Explorer"),
                 mainPanel(leafletOutput(outputId = "grizzmap")),
                 navbarMenu("More",
                            tabPanel("About"),
                            tabPanel("Summary"))
)

# UI with custom CSS
ui <- navbarPage(
    title = div(img(src = "http://www2.gov.bc.ca/assets/gov/home/gov3_bc_logo.png"),
                        "Grizzly Bear Conservation Status in British Columbia"),
    tags$style(type = 'text/css', ' .navbar { background-color: #f2f2f2;
               font.family = Arial;
               font-size = 13px;
               color: white }'),
    tabPanel("Interactive Map"),
    tabPanel("Data Explorer"),
    mainPanel(leafletOutput(outputId = "grizzmap")),
    navbarMenu("More",
               tabPanel("About"),
               tabPanel("Summary"))
)


