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
popunits_simplify <- ms_simplify(popunits, keep = 0.25) # reduce number of vertices

# Change to lat/long (4326)
popunits_simplify <- st_transform(popunits_simplify, crs = 4326)

# Drop unused metadata columns
popunits_simplify <- select(
  popunits_simplify, -c(id, SE_ANNO_CAD_DATA, VERSION_YEAR_MODIFIED, OBJECTID))

# Find centroid of polygons (for labelling)
# Note: 'popunits' w/ BC Albers CRS used because lat/long not accepted by st_centroid
popcentroid <- st_centroid(popunits$geometry)
popcentroid <- st_transform(popcentroid, crs = 4326) # convert to lat/long

# Calculate coordinates for centroid of polygons
popcoords <- st_coordinates(popcentroid) # changes to a matrix

# Spatial join
grizzdata_full <- cbind(popunits_simplify, popcoords) # cbind coords and polygons

# Rename lat and lng columns
grizzdata_full <- rename(grizzdata_full, lng = X)
grizzdata_full <- rename(grizzdata_full, lat = Y)

# Set column names to lower case
grizzdata_full <- grizzdata_full %>% rename_all(tolower)
grizzdata_full <- st_transform(grizzdata_full, crs = 4326) # convert to lat/long
grizzdata_full$population_name[grizzdata_full$population_name == " "] <- "Extirpated"

glimpse(grizzdata_full) # View

# Rename 'population name' column
grizzdata_full <- grizzdata_full %>%
  rename(gbpu_name = population_name)

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
