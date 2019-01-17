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

# Build *basic* static map for grizzly popunits/status
staticmap <- ggplot(popunits_simple) +
  geom_sf(aes(fill = STATUS)) +
  scale_fill_viridis(discrete = T, option = "magma") +
  theme_bw() +
  ggtitle("Conservation Status of Grizzly Bear Population Units in BC")
#  geom_sf_label(aes(label = GRIZZLY_BEAR_POP_UNIT_ID))
staticmap # plot map

# Create bounding box
bc_bbox <- st_as_sfc(st_bbox(bc)) # convert to sfc
bc_bbox <- st_bbox(bc_bbox) # convert to bbox
bc_bbox

# Stamen map (background) -- ends up being vector of 4gb - ah!
# map <- get_stamenmap(bbox = c(left = 275942.4, bottom = 367537.4, right = 1867409.2,
#                              top = 1735251.6 ), maptype = "toner-lite")
