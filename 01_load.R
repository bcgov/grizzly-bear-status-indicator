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
              "mapview", "readr", "bcdata", "kableExtra")
lapply(Packages, library, character.only = TRUE)


## Get British Columbia grizzly bear population unit boundaries from B.C. Data Catalogue
## from https://catalogue.data.gov.bc.ca/dataset/2bf91935-9158-4f77-9c2c-4310480e6c29
## Data is released under the Open Government Licence - British Columbia
## https://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61

## --
## Data
## --

# Get BC boundary
bc <- bc_bound()
plot(st_geometry(bc))

# Get biogeoclimatic zones
bec <- bec()

# Get grizzly pop estimate data (dated version - 2012)
bears <- read_csv("https://catalogue.data.gov.bc.ca/dataset/2bf91935-9158-4f77-9c2c-4310480e6c29/resource/4eca8c5c-ed25-46c1-835c-3d9f84b807e1/download/grizzlypopulationestimate2012.csv")
glimpse(bears)

# Load grizzly bear population units as an sf object using `bcdc_map`
popunits <- bcdc_get_geodata("grizzly-bear-population-units",
                             query = "VERSION_NAME='2012'")

plot(st_geometry(popunits))

# Load grizzly bear population units as an sfc object
# popunits <- st_read("GCPB_GRIZZLY_BEAR_POP_UNITS_SP.geojson") # saved locally - need to add to bcmaps
# popunits_sfc <- st_geometry(popunits)

# Alternative method: Reading in geojson as sp object
# popunits_sp <- geojsonio::geojson_read("GCPB_GRIZZLY_BEAR_POP_UNITS_SP.geojson", what = "sp")
