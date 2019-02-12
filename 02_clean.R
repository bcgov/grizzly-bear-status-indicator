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
popunits_simplify <- select(popunits_simplify, -c(id, SE_ANNO_CAD_DATA, VERSION_YEAR_MODIFIED, OBJECTID))

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

grizzdata_full$population_name[grizzdata_full$population_name == " "] <- "Extirpated"
grizzdata_full <- st_transform(grizzdata_full, crs = 4326) # convert to lat/long

glimpse(grizzdata_full) # View

# Summarise total pop estimate per management unit
by_gbpu <- grizzlypop_raw %>%
  group_by(GBPU) %>%
  summarise(POP_ESTIMATE = sum(Estimate), POP_DENSITY = sum(Density)) %>% # Does this make sense to sum up density?
  rename(POPULATION_NAME = GBPU) %>%
  rename_all(tolower) # Set to lower case
glimpse(by_gbpu)

# Join population + density estimates
grizzdata_full <- left_join(grizzdata_full, by_gbpu, by = "population_name")

##
## MORTALITY DATA CLEANING -----------------------------------------------------

# Mortality data - basic checks
table(is.na(bearmort_raw$GBPU_NAME)) # check for NAs in name column
gbpu_rawlist <- bearmort_raw %>% distinct(GBPU_NAME) # Make list of unique names

# Change names in new df to all lower case
bearmort <- bearmort_raw %>% rename_all(tolower)

# There are multiple observations w/ different spellings of NA-Extirpated; combine these
bearmort$gbpu_name[ bearmort$gbpu_name == "N/A - extirpated"] <- "Extirpated" # Rename rows
bearmort$gbpu_name[ bearmort$gbpu_name == "NA - extirpated"] <- "Extirpated" # Rename rows

# Make list of names for new df
gbpu_cleanlist <- bearmort %>% distinct(gbpu_name)
