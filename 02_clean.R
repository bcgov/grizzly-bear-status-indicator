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

# Simplify using mapshaper
popunits_simple <- ms_simplify(popunits, keep = 0.25) # reduce number of vertices
plot(popunits_simple[4]) # check the result for 'population name'

# Change to lat/long (4326)
popunits_simple <- st_transform(popunits_simple, crs = 4326)

## --
## Conversions for spatial data
## --

# Find centroid of polygons (for labelling)
# Note: 'popunits' w/ BC Albers CRS used because lat/long not accepted by st_centroid
popcentroid <- st_centroid(popunits$geometry)
popcentroid <- st_transform(popcentroid, crs = 4326) # convert to lat/long

# Calculate coordinates for centroid of polygons
popcoords <- st_coordinates(popcentroid) # changes to a matrix

# Spatial join
joined <- cbind(popunits_simple, popcoords) # cbind coords and polygons

# Rename lat and lng columns
joined <- rename(joined, lng = X)
joined <- rename(joined, lat = Y)
joined <- st_transform(joined, crs = 4326) # convert to lat/long

# Extract most recent iteration of popunits (there are multiple)
popunits_2012 <- filter(joined, VERSION_NAME == "2012")
