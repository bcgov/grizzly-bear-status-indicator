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
              "units", "bcdata")
lapply(Packages, library, character.only = TRUE)

#remotes::install_github("ateucher/rmapshaper")
#remotes::install_github("bcgov/bcdata")
#remotes::install_github("bcgov/envreportutils")
#devtools::install_github("dkahle/ggmap", force = T)
#remotes::install_github("bcgov/bcmaps")



## Data Download -------------------------------------------------------

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

# Import 2016 GBPU polygons (for now, until we get the newest ones)
gbpu_2018 <- read_sf(file.path(data_path, "BC_Grizzly_Results_v1_Draft_April2016.gdb"),
                     layer = "GBPU_BC_edits_v2_20150601") %>%
  transform_bc_albers()


# Import baseline data for density measure (need to update this to web mapping service)
# open web mapping service instead(
#https://openmaps.gov.bc.ca/geo/pub/WHSE_BASEMAPPING.BTM_PRESENT_LAND_USE_V1_SVW/ows?service=WMS&request=GetCapabilities

#bc_icewater <- read_sf(file.path(data_path, "BC_Grizzly_Results_v1_Draft_April2016.gdb"),
#                     layer = "BTM_IceWater") %>%
#  transform_bc_albers()

# Import baseline data for density measure (currently not on bcgw)
gbpu_hab <- read_sf(file.path(data_path, "BC_Grizzly_Results_v1_Draft_April2016.gdb"),
                       layer = "GBPU_MU_LEH_density_2015") %>%
  transform_bc_albers()

gbpu_hab <- gbpu_hab %>%
  group_by(POPULATION_NAME) %>%
  summarise(H_area_km2 = sum(AREA_KM2, na.rm = TRUE),
            H_area_wice = sum(AREA_KM2_BTMwaterIce, na.rm = TRUE),
            H_area_nowice = sum(AREA_KM2_noWaterIce, na.rm = TRUE)) %>%
  as.data.frame() %>%
  select(-Shape)
