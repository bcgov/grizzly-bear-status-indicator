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


# Loading R libraries
Packages <- c("sf", "tidyverse", "dplyr", "maptools", "devtools","bcmaps",
              "ggplot2", "leaflet", "rmapshaper", "jsonlite", "geojsonio",
              "mapview", "readr", "bcdata", "kableExtra", "envreportutils",
              "viridis", "ggmap", "RColorBrewer", "ggspatial", "ggrepel")
lapply(Packages, library, character.only = TRUE)

## --
## Data Downloads
## --

## Get British Columbia grizzly bear population unit boundaries from B.C. Data Catalogue
## from https://catalogue.data.gov.bc.ca/dataset/2bf91935-9158-4f77-9c2c-4310480e6c29
## Data is released under the Open Government Licence - British Columbia
## https://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61

# Get grizzly pop estimate data (2012)
gbpu <- read_csv("https://catalogue.data.gov.bc.ca/dataset/2bf91935-9158-4f77-9c2c-4310480e6c29/resource/4eca8c5c-ed25-46c1-835c-3d9f84b807e1/download/grizzlypopulationestimate2012.csv")
glimpse(gbpu)

# Load grizzly bear population units as an sf object using `bcdc_map`
popunits <- bcdc_get_geodata("grizzly-bear-population-units",
                             query = "VERSION_NAME='2012'")

# Get grizzly mortality data
bearmort_raw <- read_csv("https://catalogue.data.gov.bc.ca/dataset/4bc13aa2-80c9-441b-8f46-0b9574109b93/resource/c5fc42c7-67d3-4669-b281-61dc50fdef22/download/grizzlybearmortalityhistory_1976_2017.csv")

# Get biogeoclimatic zones
bec <- bec()

# Create bounding box
bc_bbox <- st_as_sfc(st_bbox(bc)) # convert to sfc
bc_bbox <- st_bbox(bc_bbox) # convert to bbox
bc_bbox
