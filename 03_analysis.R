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

## --
# Build leaflet map
## --

# Prep - colour palettes
factpal <- colorFactor(palette = 'magma', popunits$STATUS) # Assign scheme -- to be replaced with SEO default

# Generate leaflet map showing conservation status of grizzly population units
# Note: All years included
grizzmap <- leaflet() %>%
  addProviderTiles(providers$Stamen.TerrainBackground) %>%
  #addMarkers(data = popunits_simple, lng = ~ X, lat = ~Y, popup = popunits_simple$DISPLAY_NAME) %>%
  addLegend("bottomright", pal = factpal, values = popunits_simple$STATUS,
            title = "Conservation Status",
            opacity = 1) %>%
  addPolygons(data = popunits_simple,
              stroke = T, weight = 1, color = "white", # Add border to polygons
              fillOpacity = 0.3, # Polygon fill
              fillColor = ~factpal(popunits_simple$STATUS),
              highlight = highlightOptions( # Highlight interaction for mouse hover
                weight = 3,
                color = "yellow",
                bringToFront = T))
grizzmap # Plot the map

# Not finished:
#  addLabelOnlyMarkers(data = popunits_2012,
#                      label = as.character(popunits_2012$POPULATION_NAME),
#                      labelOptions = leaflet::labelOptions(
#                        noHide = F,
#                        direction = 'top',
#                        textOnly = T,
#                        opacity = 1))


