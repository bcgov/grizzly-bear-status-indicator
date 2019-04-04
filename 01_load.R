# Copyright 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


# Loading R libraries ---------------------------------------------------
Packages <- c("sf", "tidyverse", "dplyr", "maptools", "devtools","bcmaps",
              "ggplot2", "leaflet", "rmapshaper", "jsonlite", "geojsonio",
              "mapview", "readr", "bcdata", "kableExtra", "envreportutils",
              "viridis", "ggmap", "RColorBrewer", "ggspatial", "ggrepel",
              "svglite", "Cairo", "purrr", "shiny", "htmltools", "here")
lapply(Packages, library, character.only = TRUE)
# devtools::install_github("dkahle/ggmap", force = T)

# Install envreportutils
# remotes::install_github("bcgov/envreportutils", force = T)

##
## Data Downloads -------------------------------------------------------

## Get British Columbia grizzly bear population unit boundaries from B.C. Data Catalogue
## from https://catalogue.data.gov.bc.ca/dataset/2bf91935-9158-4f77-9c2c-4310480e6c29
## Data is released under the Open Government Licence - British Columbia
## https://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61

# Import grizzly bear threat calculator data from csv prior to the following steps
# Threat calculator data not yet in databc warehouse
threat_calc <- as_tibble(Threat_Calc) %>%
  rename_all(tolower)

# Import 2012 GBPU polygons
popunits <- bcdc_get_geodata("grizzly-bear-population-units",
                             query = "VERSION_NAME='2012'")

# Import 2015 GBPU polygons
gbpu_2015 <- st_read("C:/dev/grizzly-bear-status-indicator/gbpu_2015.shp")
plot(st_geometry(gbpu_2015))

# Get BC boundary
boundbc <- bc_bound()

# Get biogeoclimatic zones
# bec <- bec()

# Create bounding box
# bc_bbox <- st_as_sfc(st_bbox(boundbc)) # convert to sfc
# bc_bbox <- st_bbox(bc_bbox) # convert to bbox
# bc_bbox

# Import shp as sf
library(here)
habclass <- st_read("C:/dev/grizzly-bear-status-indicator/habclass.shp")
plot(st_geometry(habclass))
# habclass <- ms_simplify(habclass) # CRASHES - DO NOT RUN
