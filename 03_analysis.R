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

# ----------------------------------------------------------------------------
# STATIC MAPPING -------------------------------------------------------------
staticmap <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = calcrank), color = "white", size = 0.1) +
  labs(title = "Conservation Status of Grizzly Bear Population Units in BC",
       col = "Conservation Rank",
       fill = "Threat Category") +
  scale_fill_viridis(alpha = 0.6, discrete = T, option = "viridis",
                     direction = -1, na.value = "darkgrey") +
  theme_soe() + theme(plot.title = element_text(hjust = 0.5),
                      axis.title.x = element_blank(),
                      axis.title.y = element_blank(),
                      legend.background = element_rect(
                        fill = "lightgrey", size = 0.5,
                        linetype = "solid", colour = "darkgrey")) +
  geom_text(aes(label = grizzdata_full$gbpu_name, x = grizzdata_full$lng,
                y = grizzdata_full$lat), size = 2, check_overlap = T)
  #geom_text_repel(aes(label = gbpu_name, x = lng, y = lat),
                  #size = 2, force =  0.5) # Needs some tweaking - some labels off polygons
staticmap # plot map

# Get stamen basemap (terrain)
stamenbc <- get_stamenmap(bbox = c(-139.658203,48.5,-113.071289,60.261617),
                          zoom = 7, maptype = "terrain-background",
                          where = "/dev/stamen/")
# saveRDS(stamenbc, file = "/dev/stamen.Rds")
# readRDS(stamenbc)
plot(stamenbc) # View basemap

# Plot stamen map with terrain basemap
static_ggmap <- ggmap(stamenbc) + # Generate new map
  geom_sf(data = grizzdata_full, aes(fill = calcrank), inherit.aes = F,
          color = "white", size = 0.01) + # plot with boundary
  #geom_text(aes(label = grizzdata_full$gbpu_name, x = grizzdata_full$lng,
  #              y = grizzdata_full$lat")) +
  # geom_label(data = grizzdata_full$gbpu_name) +
  theme_soe() + scale_fill_viridis(discrete = T, alpha = 0.5,
                                   option = "viridis", direction = -1,
                                   na.value = "darkgrey") +
  labs(title = "Conservation Status of Grizzly Bear Population Units in BC",
       fill = "Conservation Rank") +
  theme(plot.title = element_text(hjust = 0.5), axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.background = element_rect(
          fill = "lightgrey", size = 0.5, linetype = "solid",
          colour = "darkgrey"))
plot(static_ggmap)

# Clip + mask raster to BC boundary
# stamenbc_crop <- raster::crop(stamenbc, bc_boundary)
