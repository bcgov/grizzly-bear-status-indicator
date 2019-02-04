# Loading R libraries
Packages <- c("tidyverse", "shiny", "devtools", "bcmaps",
              "ggplot2", "leaflet", "rmapshaper", "viridis",
              "bcdata", "envreportutils","ggspatial", "ggrepel", "htmltools")
lapply(Packages, library, character.only = TRUE)

# Load data
grizzdata <- popunits_xy

# Custom icon from glyphicon
tree <- icon("tree-conifer", lib = "glyphicon")
