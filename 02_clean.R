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

popiso_table <- tribble(
  ~popiso, ~popiso_rank_adj,
  "AA", 4,
  "AB", 4,
  "AC", 4,
  "AD", 3,
  "BA", 4,
  "BB", 1.5,
  "BC", 1,
  "BD", 0.5,
  "CA", 4,
  "CB", 1.5,
  "CC", 1,
  "CD", 0,
  "DA", 3,
  "DB", 1,
  "DC", 0.5,
  "DD", 0,
  "EA", 2,
  "EB", 1,
  "EC", 0.5,
  "ED", 0
)

threat_table <- tribble(
  ~threat_class, ~threat_rank_adj,
  "Very High", 2,
  "High", 1.5,
  "Medium", 1.0,
  "Low", 0,
  "Negligible", 0
)

threat_calc <- threat_calc %>%
  left_join(popiso_table, by = "popiso") %>%
  left_join(threat_table, by = "threat_class") %>%
  mutate(calc_rank_check = 5 - trend*-1 - popiso_rank_adj - threat_rank_adj)


## DATA CLEANING ---------------------------------------------------------

# Find centroid of polygons (for labelling)
# Note: BC Albers CRS used because lat/long not accepted by st_centroid
popcentroid <- st_centroid(st_geometry(gbpu_2018)) %>%
  st_transform(popcentroid, crs = 4326)

# Spatial join
grizzdata_full <- cbind(gbpu_2018,
                        st_coordinates(popcentroid)) # cbind coords and polygons

# Rename lat and lng columns
grizzdata_full <- rename(grizzdata_full, lng = X, lat = Y) %>%
  st_transform(4326) # convert to lat/long

# Rename 'population name' column
grizzdata_full <- grizzdata_full %>%
  rename_all(tolower) %>%
  rename(gbpu_name = population_name)

# Join GBPU polygons (popunits) and threat classification data
grizzdata_full <- left_join(grizzdata_full, threat_calc, by = "gbpu_name")

# Give NA (extirpated) gbpu names
grizzdata_full <- mutate(grizzdata_full,
                         gbpu_name = as.character(gbpu_name),
                         gbpu_name = case_when(
                           grizzly_bear_population_tag == 47 ~ "Northeast",
                           grizzly_bear_population_tag == 48 ~ "Central Interior",
                           grizzly_bear_population_tag == 53 ~ "Lower Mainland",
                           grizzly_bear_population_tag == 81 ~ "Sunshine Coast",
                           TRUE ~ gbpu_name
                         ))

grizzdata_full <- mutate(grizzdata_full,
                         isolation = as.character(popiso),
                         isolation = case_when(
                           str_detect(isolation, "^[A-E]A$") ~ "Totally Isolated",
                           str_detect(isolation, "^[A-E]B$") ~ "Highly Isolated",
                           str_detect(isolation, "^[A-E]C$") ~ "Moderate Isolated",
                           str_detect(isolation, "^[A-E]D$") ~ "Not Isolated")
                         )

grizzdata_full <- mutate(grizzdata_full,
                         con_stats = as.character(calcsrank),
                         con_stats = case_when(
                           str_detect(calcsrank, "1") ~ "Extreme",
                           str_detect(calcsrank, "2") ~ "High",
                           str_detect(calcsrank, "3") ~ "Moderate",
                           str_detect(calcsrank, "4") ~ "Low",
                           str_detect(calcsrank, "5") ~ "Negligible")
)


# Add population density column
grizzdata_full <- mutate(grizzdata_full,
                         area_sq_km = round(as.numeric(set_units(st_area(geometry), km2)), digits = 0),
                         use_area_sq_km = round(as.numeric(h_area_nowice),digits = 0),
                         pop_density = round(as.numeric(gbpu.pop / use_area_sq_km * 1000), digits = 0)
)

# Change threat class column to ordered factor
grizzdata_full <- grizzdata_full %>%
  mutate(threat_class = ifelse(threat_class == "VHigh", "Very High", threat_class))

grizzdata_full$threat_class <- factor(grizzdata_full$threat_class, ordered = TRUE,
                                      levels = c("Very High", "High", "Medium", "Low", "Negligible"))


# Replace NAs in trend column with  "Data Deficient"
grizzdata_full$trend <- grizzdata_full$trend %>% replace_na("Data Deficient")

# Simplify vertices of GBPU polygons
grizzdata_full <- ms_simplify(grizzdata_full, keep = 0.25) # reduce number of vertices

# create spatial subset to add to mortality dataset
grizz_morts <- grizzdata_full %>%
  select(grizzly_bear_pop_unit_id, grizzly_bear_population_tag,
         gbpu_name, display_name, status, geometry) %>%
  left_join(morts, by = c("grizzly_bear_population_tag" = "GBPU_ID"))

# remove extra columns:
grizzdata_full <- grizzdata_full %>%
  select(-c(display_name, grizzly_bear_pop_unit_id, grizzly_bear_population_tag,
            display_name,within_bc_ind, version_name, version_year_modified,
            h_area_km2, h_area_wice , h_area_nowice, calc_rank_check, expertrank, expertoverallthreat,
            preadj_rank_number, rank_number, residential,
            agriculture, energy, transportation, biouse , humanintrusion,
            climatechange))


# Write grizzly data file to disk
if (!dir.exists("data")) dir.create("data")
saveRDS(grizzdata_full, file = "data/grizzdata_full.rds")
saveRDS(grizz_morts, file = "data/grizzdata_morts.rds")

# Create mortality dataset with common naming convention

#


