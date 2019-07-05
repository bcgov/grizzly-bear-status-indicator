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

## SPATIAL DATA CLEANING ---------------------------------------------------------
# Simplify vertices of GBPU polygons
gbpu_simplify <- ms_simplify(gbpu_2015, keep = 0.25) # reduce number of vertices

# Simplify vertices of management unit polygons
mu_simplify <- ms_simplify(gbpu_mu_dens, keep = 0.25)
plot(st_geometry(mu_simplify))

# Transform to BC Albers
gbpu_simplify <- st_transform(gbpu_simplify, crs = 3005)

# Find centroid of polygons (for labelling)
# Note: BC Albers CRS used because lat/long not accepted by st_centroid
popcentroid <- st_centroid(st_geometry(gbpu_simplify))
popcentroid <- st_transform(popcentroid, crs = 4326) # convert to lat/long

# Calculate coordinates for centroid of polygons
popcoords <- st_coordinates(popcentroid) # changes to a matrix

# Spatial join
grizzdata_full <- cbind(gbpu_simplify, popcoords) # cbind coords and polygons

# Rename lat and lng columns
grizzdata_full <- rename(grizzdata_full, lng = X, lat = Y) %>%
  st_transform(4326) # convert to lat/long

# Rename 'population name' column
grizzdata_full <- grizzdata_full %>%
  rename_all(tolower) %>%
  rename(gbpu_name = population)

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


# Write grizzly data file to disk
# saveRDS(grizzdata_full, file = "data/grizzdata_full.rds")

# Not to be used in new version unless needed:
# Summarise total pop estimate per management unit
by_gbpu <- grizzlypop_raw %>%
  group_by(GBPU) %>%
  summarise(POP_ESTIMATE = sum(Estimate),
            Total_Area = sum(Total_Area),
            # Recalculate Density (bears / 1000 km^2)
            POP_DENSITY = round(POP_ESTIMATE / (Total_Area / 1000))) %>%
  rename(gbpu_name = GBPU) %>%
  rename_all(tolower) # Set to lower case
glimpse(by_gbpu)



