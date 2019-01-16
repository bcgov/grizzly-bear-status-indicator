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
plot(popunits_simple[3]) # check the result for 'population name'

# Change to lat/long (4326)
popunits_simple <- st_transform(popunits_simple, crs = 4326)

## --
## Spatial conversions
## --

# Find centroid of polygons - might be useful for labelling
popcentroid <- st_centroid(popunits_simple$geometry)

# Calculate coordinates for centroid of polygons
popcoords <- st_coordinates(popcentroid) # changes to a matrix -- ughhh

# Convert to tibble
tibble::as.tibble(popcoords)

# Convert to sf object
popcoords <- popcoords %>%
  as.data.frame %>%
  sf::st_as_sf(coords = c(1,2)) # gets rid of XY columns :(

# Spatial join

