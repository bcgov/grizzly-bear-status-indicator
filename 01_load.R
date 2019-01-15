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
              "ggplot2", "leaflet", "rmapshaper", "jsonlite", "geojsonio", "mapview")
lapply(Packages, library, character.only = TRUE)

## Get British Columbia grizzly bear population unit boundaries from B.C. Data Catalogue
## from https://catalogue.data.gov.bc.ca/dataset/24c899ee-ef73-44a2-8569-a0d6b094e60c
## Data is released under the Open Government License - British Columbia
## https://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61

# Get BC boundary
bc <- bc_bound()
plot(st_geometry(bc))

# Get biogeoclimatic zones
bec <- bec()

# Get grizzly pop estimate data (dated version - 2012)
bears <- read.csv("https://catalogue.data.gov.bc.ca/dataset/2bf91935-9158-4f77-9c2c-4310480e6c29/resource/4eca8c5c-ed25-46c1-835c-3d9f84b807e1/download/grizzlypopulationestimate2012.csv")

# Load grizzly bear population units as an sfc object
popunits <- st_read("GCPB_GRIZZLY_BEAR_POP_UNITS_SP.geojson") # saved locally - need to add to bcmaps
popunits <- st_geometry(popunits)

# Alternative method: Reading in geojson as sp object
# popunits_sp <- geojsonio::geojson_read("GCPB_GRIZZLY_BEAR_POP_UNITS_SP.geojson", what = "sp")
