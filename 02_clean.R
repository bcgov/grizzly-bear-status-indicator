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

# Simplify population unit polygons using mapshaper
popunits_simple <- ms_simplify(popunits, keep = 0.25) # reduce number of vertices
plot(popunits_simple[4]) # check the result for 'population name'

# Change to lat/long (4326)
popunits_simplify <- st_transform(popunits_simple, crs = 4326)

# Find centroid of polygons (for labelling)
# Note: 'popunits' w/ BC Albers CRS used because lat/long not accepted by st_centroid
popcentroid <- st_centroid(popunits$geometry)
popcentroid <- st_transform(popcentroid, crs = 4326) # convert to lat/long

# Calculate coordinates for centroid of polygons
popcoords <- st_coordinates(popcentroid) # changes to a matrix

# Spatial join
popunits_xy <- cbind(popunits_simplify, popcoords) # cbind coords and polygons

# Rename lat and lng columns
popunits_xy <- rename(popunits_xy, lng = X)
popunits_xy <- rename(popunits_xy, lat = Y)
popunits_xy <- st_transform(joined, crs = 4326) # convert to lat/long

# Summarise total pop estimate per management unit
by_gbpu <- grizzlypop_raw %>%
  group_by(GBPU) %>%
  summarise(Estimate = sum(Estimate), Density = sum(Density)) %>% # Does this make sense to sum up density?
  rename(POPULATION_NAME = GBPU)
glimpse(by_gbpu)

# Join population + density estimates
popunits_xy <- left_join(popunits_xy, by_gbpu, by = "POPULATION_NAME")
glimpse(popunits_xy)

## --
## MORTALITY DATA CLEANING
## --

# Mortality data - basic checks
table(is.na(bearmort_raw$GBPU_NAME)) # check for NAs in name column
gbpu_rawlist <- bearmort_raw %>% distinct(GBPU_NAME) # Three rows corresponding to NA in raw data
bearmort$GBPU_NAME[ bearmort$GBPU_NAME == "N/A - extirpated"] <- "Extirpated" # Rename rows
bearmort$GBPU_NAME[ bearmort$GBPU_NAME == "NA - extirpated"] <- "Extirpated" # Rename rows
bearmort$GBPU_NAME[ bearmort$GBPU_NAME == "NA"] <- "Extirpated" # Rename rows

# Make list of names for new df
gbpu_cleanlist <- bearmort %>% distinct(GBPU_NAME)




