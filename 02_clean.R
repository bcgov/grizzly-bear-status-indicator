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
  "VHigh", 2,
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
gbpu_2018 <- gbpu_2018 %>%
  group_by(POPULATION_NAME) %>%
  left_join(gbpu_hab)


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
                           str_detect(isolation, "^[A-E]A$") ~ "Isolated (>90%)",
                           str_detect(isolation, "^[A-E]B$") ~ "Moderately-Highly Isolated (66-90%)",
                           str_detect(isolation, "^[A-E]C$") ~ "Somewhat Isolated (25-66%)",
                           str_detect(isolation, "^[A-E]D$") ~ "Not Isolated (<25%)")
                         )


# Add population density column

grizzdata_full <- mutate(grizzdata_full,
                         area_sq_km = as.numeric(set_units(st_area(geometry), km2)),
                         use_area_sq_km = as.numeric(set_units)
                         pop_density = as.numeric(adults / area_sq_km * 1000)
)

# Round to 2 decimal places
grizzdata_full$pop_density <- round(grizzdata_full$pop_density, digits = 2)
grizzdata_full$area_sq_km <- round(grizzdata_full$area_sq_km, digits = 2)

# Change threat class column to ordered factor
grizzdata_full$threat_class <- factor(grizzdata_full$threat_class, ordered = TRUE,
                                      levels = c("VHigh", "High", "Medium", "Low", "Negligible"))

# Replace NAs in trend column with  "Data Deficient"
grizzdata_full$trend <- grizzdata_full$trend %>% replace_na("Data Deficient")

# Simplify vertices of GBPU polygons
grizzdata_full <- ms_simplify(grizzdata_full, keep = 0.25) # reduce number of vertices


# add numeric values to output table to calculate figures for Management Status
grizzdata_full <- grizzdata_full %>%
  left_join(popiso_table, by = "popiso") %>%
  left_join(threat_table, by = "threat_class") %>%
  mutate(calc_rank_check = 5 - as.numeric(trend) - popiso_rank_adj - threat_rank_adj)


grizzdata_full <- grizzdata_full %>%
  mutate(threat_class = ifelse(threat_class == "VHigh","Very High",paste(threat_class)))


# Write grizzly data file to disk
if (!dir.exists("data")) dir.create("data")
saveRDS(grizzdata_full, file = "data/grizzdata_full.rds")
