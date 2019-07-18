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

## DATA CLEANING ---------------------------------------------------------
gbpu_2018 <- gbpu_2018 %>%
  group_by(POPULATION_NAME)

# Find centroid of polygons (for labelling)
# Note: BC Albers CRS used because lat/long not accepted by st_centroid
popcentroid <- st_centroid(st_geometry(gbpu_2018))
popcentroid <- st_transform(popcentroid, crs = 4326) # convert to lat/long

# Calculate coordinates for centroid of polygons
popcoords <- st_coordinates(popcentroid)

# Spatial join
grizzdata_full <- cbind(gbpu_2018, popcoords) # cbind coords and polygons

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

# Add population density column
grizzdata_full <- mutate(grizzdata_full,
                         area_sq_km = as.numeric(set_units(st_area(geometry), km2)),
                         pop_density = as.numeric(adults / area_sq_km * 1000)
)

# Round to 2 decimal places
grizzdata_full$pop_density <- round(grizzdata_full$pop_density, digits = 2)

grizzdata_full$threat_class <- factor(grizzdata_full$threat_class, ordered = TRUE)

# Simplify vertices of GBPU polygons
grizzdata_full <- ms_simplify(grizzdata_full, keep = 0.25) # reduce number of vertices

# Write grizzly data file to disk
dir.create("data")
saveRDS(grizzdata_full, file = "data/grizzdata_full.rds")


