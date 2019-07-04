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
Packages <- c("sf", "tidyverse", "maptools", "devtools","bcmaps",
              "leaflet", "rmapshaper", "bcdata", "envreportutils",
              "viridis", "ggmap", "ggspatial", "here",
              "ggrepel", "svglite", "Cairo", "shiny", "htmltools")
lapply(Packages, library, character.only = TRUE)

# remotes::install_github("bcgov/bcdata")
# install_github("bcgov/envreportutils")
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
# (Not yet in DataBC)
# Threat calculator data not yet in databc warehouse
threat_calc <- as_tibble(Threat_Calc) %>%
  rename_all(tolower)

# Import 2015 GBPU polygons
gbpu_2018 <- st_read("C:/dev/grizzly-bear-status-indicator/data/gbpu_2018.shp")
plot(st_geometry(gbpu_2018))

# Import management unit polygons
gbpu_mu_dens <- st_read("C:/dev/grizzly-bear-status-indicator/data/gbpu_mu_leh_density.shp")
plot(st_geometry(gbpu_mu_dens))

# Create bounding box
# bc_bbox <- st_as_sfc(st_bbox(boundbc)) # convert to sfc
# bc_bbox <- st_bbox(bc_bbox) # convert to bbox
# bc_bbox

# Import grizzly BEI polygons (2019) as sf
habclass <- st_read("C:/dev/grizzly-bear-status-indicator/habclass.shp")
plot(st_geometry(habclass))

habclass_simp <- ms_simplify(habclass, keep = 0.1, sys = TRUE)
plot(habclass_simp[2])
# saveRDS(habclass_simp, "habclass_simp.rds")
