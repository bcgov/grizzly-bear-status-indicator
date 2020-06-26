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
              "leaflet", "rmapshaper", "envreportutils",
              "viridis", "here", "readxl","bcdata", "units",
              "svglite", "Cairo", "shiny", "htmltools")
lapply(Packages, library, character.only = TRUE)

#remotes::install_github("ateucher/rmapshaper")
#remotes::install_github("bcgov/bcdata")
#remotes::install_github("bcgov/envreportutils")
#devtools::install_github("dkahle/ggmap", force = T)
#remotes::install_github("bcgov/bcmaps")


## Data Download -------------------------------------------------------

## Get British Columbia grizzly bear data from B.C. Data Catalogue
## Data is released under the Open Government Licence - British Columbia


# 1) Import conservation ranking table:
# https://catalogue.data.gov.bc.ca/dataset/e08876a1-3f9c-46bf-b69a-3d88de1da725


threat_calc <- bcdc_get_data(record = 'e08876a1-3f9c-46bf-b69a-3d88de1da725',
                             resource = '7282667b-185a-4f08-9d99-13a2e5ada1d4') %>%
  rename_all(tolower) %>%
  rename(gbpu_name = gbpu,
         gbpu.pop = popnest2018,
         threat_class = overal_threat)


# 2) Import grizzly bear population unite (gbpu) spatial data

gbpu_poly_raw <- bcdc_get_data("https://catalogue.data.gov.bc.ca/dataset/caa22f7a-87df-4f31-89e0-d5295ec5c725")

gbpu_poly <- gbpu_poly_raw %>%
  filter(VERSION_NAME == 2018) %>%
  select(-c(id, VERSION_NAME, VERSION_YEAR_MODIFIED,
            SE_ANNO_CAD_DATA, FEATURE_LENGTH_M,
            WITHIN_BC_IND)) %>%
  mutate(gbpu_name = POPULATION_NAME)

names(gbpu_poly) <- tolower(names(gbpu_poly))


# 3) Import population data from data catalogue

pop.raw <- bcdc_get_data("https://catalogue.data.gov.bc.ca/dataset/2bf91935-9158-4f77-9c2c-4310480e6c29",
                         resource = '6406840f-9525-4544-9c36-e725fb2e399a')

pop <- pop.raw %>%
  rename_all(tolower) %>%
  rename(population_name = population_name,
         pop_est = gbpu_est_pop_2018,
         pop_area = gbpu_area_km2_nowaterice) %>%
  select(c(population_name, pop_area, pop_est))
# temporary fix to consolidate names in 2012 data set (remove once updated population data is used)
 # mutate(gbpu_name = case_when(
#    gbpu_name == "Central Purcells" ~ "Central-South Purcells",
#    gbpu_name == "North Purcell" ~ "North Purcells",
#    TRUE ~ gbpu_name
#  ))

gbpu_data <-  left_join(gbpu_poly, pop, by = "population_name")

# 4. Import mortality data set
# (https://catalogue.data.gov.bc.ca/dataset/history-of-grizzly-bear-mortalities)

morts <- bcdc_get_data("4bc13aa2-80c9-441b-8f46-0b9574109b93")




