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
              "viridis", "ggmap", "ggspatial", "here", "readxl",
              "ggrepel", "svglite", "Cairo", "shiny", "htmltools",
              "units")
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
data_path <- soe_path("Operations ORCS/Data - Working/plants_animals/grizzly/2019/Raw Data")

threat_calc <- read_xls(file.path(data_path, "Threat_Calc.xls")) %>%
  rename_all(tolower)

# Import 2015 GBPU polygons
gbpu_2018 <- st_read(file.path(data_path, "gbpu_2018.shp"))
plot(st_geometry(gbpu_2018))

# Create bounding box
# bc_bbox <- st_as_sfc(st_bbox(boundbc)) # convert to sfc
# bc_bbox <- st_bbox(bc_bbox) # convert to bbox
# bc_bbox

# Import grizzly BEC/Ecosection polygons (2019) as sf
habclass <- bcdc_get_data(record = 'dba6c78a-1bc1-4d4f-b75c-96b5b0e7fd30',
                          resource = 'd23da745-c8c5-4241-b03d-5654591e117c')
plot(st_geometry(habclass))

habclass_simp <- ms_simplify(habclass, keep = 0.1, sys = TRUE)
plot(st_geometry(habclass_simp))
# saveRDS(habclass_simp, "habclass_simp.rds")
