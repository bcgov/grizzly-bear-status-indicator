# Loading R libraries
Packages <- c("tidyverse", "shiny", "devtools", "bcmaps",
              "ggplot2", "leaflet", "rmapshaper", "viridis",
              "bcdata", "envreportutils","ggspatial", "ggrepel", "htmltools")
lapply(Packages, library, character.only = TRUE)

# Custom icon from glyphicon
tree <- icon("tree-conifer", lib = "glyphicon")
