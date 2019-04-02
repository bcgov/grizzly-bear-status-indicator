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

# Create colour palette for future mapping (not currently used)
# pal <- c("Extirpated" = "firebrick2", "Threatened" = "yellow1", "Viable" = "forestgreen")

## STATIC MAPPING -------------------------------------------------------------
staticmap <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = rankcode), color = "white", size = 0.1) +
  labs(title = "Conservation Status of Grizzly Bear Population Units in BC",
       col = "Conservation Rank") +
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
stamenbc <- get_stamenmap(bbox = c(-139.658203,48.806863,-113.071289,60.261617),
                          zoom = 7, maptype = "terrain-background", where = "/dev/stamen/")
# saveRDS(stamenbc, file = "/dev/stamen.Rds")
# readRDS(stamenbc)
plot(stamenbc) # View basemap

# Plot stamen map with terrain basemap
static_ggmap <- ggmap(stamenbc) + # Generate new map
  geom_sf(data = grizzdata_full, aes(fill = rankcode), inherit.aes = F,
          color = "white", size = 0.01) + # plot with boundary
  theme_soe() + scale_fill_viridis(discrete = T, alpha = 0.5,
                                   option = "viridis", direction = -1,
                                   na.value = "darkgrey") +
  labs(title = "Conservation Status of Grizzly Bear Population Units in BC",
       fill = "Rank Code") +
  theme(plot.title = element_text(hjust = 0.5), axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.background = element_rect(
          fill = "lightgrey", size = 0.5, linetype = "solid", colour = "darkgrey"))
  # geom_text(aes(label = grizzdata_full$gbpu_name,
  #              x = grizzdata_full$lng, y = grizzdata_full$lat))
plot(static_ggmap)

# Clip + mask raster to BC boundary
# stamenbc_crop <- raster::crop(stamenbc, bc_boundary)

## POPULATION ESTIMATE MAPPING ------------------------------------------------
# Plot basic POPULATION estimate per management unit
popplot <- ggplot(grizzdata_full) +
  geom_col(aes(x = reorder(gbpu_name, -adults), y = adults)) +
  theme_soe() +
  scale_y_continuous("Population Estimate") +
  scale_x_discrete("Population Unit") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + # rotate labels
  ggtitle("Grizzly Bear Population Estimate per Unit") +
  theme(plot.title = element_text(hjust = 0.5))
popplot # Display plot

# Build static grizzly population choropleth
grizzlypopmap <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = adults)) +
  labs(title = "Grizzly Bear Population Estimates for British Columbia",
       fill = "Population Estimate") +
  theme_minimal() + theme(plot.title = element_text(hjust = 0.5),
                          axis.title.x = element_blank(),
                          axis.title.y = element_blank()) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .5, na.value = "darkgrey") +
  geom_text(aes(label = grizzdata_full$gbpu_name, x = grizzdata_full$lng,
                y = grizzdata_full$lat), size = 2, check_overlap = T)
grizzlypopmap # plot map

## POPULATION DENSITY MAPPING: May not be needed for updated version ----------
# Build  static grizzly density choropleth
grizzlydensmap <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = pop_density)) +
  labs(title = "Grizzly Bear Population Density in British Columbia",
       fill = "Population Density") + # Legend title
  theme_minimal() + theme(plot.title = element_text(hjust = 0.5), # Center main title
                          axis.title.x = element_blank(), # Remove xy labels
                          axis.title.y = element_blank()) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .5) + # Set colour (viridis)
  geom_text_repel(aes(label = gbpu_name, x = lng, y = lat),
                  size = 2, force =  0.5) # Offset labels
#geom_text(aes(label = gbpu_name, x = lng, y = lat),
#position = position_dodge(width = 0.8), size = 3) # Needs some tweaking - some labels off polygons
grizzlydensmap # plot map

# Plot basic density estimate per management unit
densplot <- ggplot(by_gbpu) +
  geom_col(aes(x = reorder(gbpu_name, -pop_density), y = pop_density)) +
  theme_soe() +
  scale_y_continuous("Population Density Estimate") +
  scale_x_discrete("Population Unit") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + # rotate labels
  ggtitle("Grizzly Bear Population Density Estimate per Unit") +
  theme(plot.title = element_text(hjust = 0.5))
densplot # Display plot
