# Loading R libraries
Packages <- c("tidyverse", "shiny", "devtools", "bcmaps",
              "ggplot2", "leaflet", "rmapshaper", "viridis",
              "bcdata", "envreportutils","ggspatial", "ggrepel")
lapply(Packages, library, character.only = TRUE)

# Load data
grizzdata <- popunits_xy

# Custom icon from 'www' reference file in shiny
pawicon <- makeIcon("/dev/grizzly-bear-status-indicator/shiny/www/grizzly_paw_icon.png", iconWidth = 24, iconHeight = 24)

# Custom icon from glyphicon
tree <- icon("tree-conifer", lib = "glyphicon")

paw <- img(src=paste0(grizzly_paw_icon,".png"))
