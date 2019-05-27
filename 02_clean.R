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
# Simplify population unit polygons using mapshaper
gbpu_simplify <- ms_simplify(gbpu_2015, keep = 0.25) # reduce number of vertices

# Simplify management units
mu_simplify <- ms_simplify(gbpu_mu_dens, keep = 0.25)
plot(st_geometry(mu_simplify))

# Transform to BC Albers
gbpu_simplify <- st_transform(gbpu_simplify, crs = 3005)

# Find centroid of polygons (for labelling)
# Note: BC Albers CRS used because lat/long not accepted by st_centroid
popcentroid <- st_centroid(gbpu_simplify$geometry)
popcentroid <- st_transform(popcentroid, crs = 4326) # convert to lat/long

# Calculate coordinates for centroid of polygons
popcoords <- st_coordinates(popcentroid) # changes to a matrix

# Spatial join
grizzdata_full <- cbind(gbpu_simplify, popcoords) # cbind coords and polygons

# Rename lat and lng columns
grizzdata_full <- rename(grizzdata_full, lng = X)
grizzdata_full <- rename(grizzdata_full, lat = Y)
grizzdata_full <- st_transform(grizzdata_full, crs = 4326) # convert to lat/long

# Transform BACK to BC Albers
grizzdata_full <- st_transform(grizzdata_full, crs = 3005)

# Rename 'population name' column
grizzdata_full <- grizzdata_full %>%
  rename_all(tolower) %>%
  rename(gbpu_name = population)

# Join GBPU polygons (popunits) and threat classification data
grizzdata_full <- left_join(grizzdata_full, threat_calc, by = "gbpu_name")

# Rename NA gbpu names to Extirpated
grizzdata_full$gbpu_name <- as.character(grizzdata_full$gbpu_name) # as char
grizzdata_full$gbpu_name[is.na(grizzdata_full$gbpu_name)] <- "Extirpated"

# Write grizzly polygons to disk
saveRDS(grizzdata_full,file = "grizzdata_full.rds")

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



