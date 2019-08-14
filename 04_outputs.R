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
library(dplyr)

if (!exists("grizzdata_full")) load("data/grizzdata_full.rds")

# create static summary plots
sdata <- grizzdata_full %>%
  group_by(threat_class) %>%
  select(-c(geometry)) %>%
  summarize(count = n()) %>%
  filter(!is.na(threat_class))

sdata <- as.data.frame(sdata)

# drop geometry

overall_threat_plot <-
  ggplot(sdata, aes(y = count, x = threat_class)) +
  geom_bar(stat = "identity", aes(fill = as.factor(threat_class)), show.legend = FALSE) +
  scale_fill_brewer(palette = "Set1") +
  scale_x_discrete(limits = c("Negligible", "Low", "Medium", "High", "VHigh"))+
  geom_text(aes(label=count), vjust=0.5, hjust = 2) +
  coord_flip() +
  labs(y = "Number of Grizzly Bear Population Units (GBPU)", x = "Overall Threat")+
  ggtitle("Overall threat impacts to Grizzly Bear Population Units") +
  theme_soe()

## Printing plots for web in SVG formats (and PNG)
svg_px("./print_ver/othreat_plot.svg", width = 500, height = 400)
plot(overall_threat_plot)
dev.off()

png_retina(filename = "./print_ver/othreat_plot.png", width = 500, height = 400,
           units = "px", type = "cairo-png", antialias = "default")
plot(overall_threat_plot)
dev.off()


# generate sumary plot per threat

if (!exists("total_threats")) load("data/total_threats.rds")

tdata <- total_threats %>%
  group_by(threat, ranking) %>%
  summarise(count = length(gbpu_name))


tdata$ranking <- factor(tdata$ranking, ordered = TRUE,
                                levels = c("Negligible", "Low", "Medium", "High"))


threat_sum_plot <-
  ggplot(tdata, aes(x = threat, y = count,
                              fill = ranking)) +
  geom_bar(stat = "identity") + # Add bar for each threat variable
  scale_fill_brewer("Threat Level", palette = "Set2") +
  scale_y_continuous(limits = c(0,55), breaks = seq(0,50,10))+
  ggtitle("Estimated impact of threat catergories") +
  labs(x = "Threat", y = "Number of Grizzly Bear Population Units (n = 55)",
       fill = "Ranking") +
  guides(fill= guide_legend (reverse = TRUE))+
  coord_flip() +
  theme_soe()

## Printing plots for web in SVG formats (and PNG)
svg_px("./print_ver/threat_sum_plot.svg", width = 500, height = 400)
plot(threat_sum_plot)
dev.off()

png_retina(filename = "./print_ver/threat_sum_plot.png", width = 500, height = 400,
           units = "px", type = "cairo-png", antialias = "default")
plot(threat_sum_plot)
dev.off()



## ----------------------------------------------------------------------------
## STATIC MAPPING
## ----------------------------------------------------------------------------
staticmap <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = calcrank), color = "white", size = 0.1) +
  labs(title = "Conservation Status of Grizzly Bear Population Units in BC",
       col = "Conservation Rank",
       fill = "Management Rank") +
  scale_fill_viridis(alpha = 0.6, discrete = T, option = "viridis",
                     direction = -1, na.value = "darkgrey") +
  theme_soe() + theme(plot.title = element_text(hjust = 0.5),
                      axis.title.x = element_blank(),
                      axis.title.y = element_blank(),
                      legend.background = element_rect(
                        fill = "lightgrey", size = 0.5,
                        linetype = "solid", colour = "darkgrey")) +
  geom_text(aes(label = grizzdata_full$gbpu_name, x = grizzdata_full$lng,
                y = grizzdata_full$lat), size = 2, check_overlap = T) #+
  #geom_text_repel(aes(label = gbpu_name, x = lng, y = lat), size = 2, force = 0.5) # Needs some tweaking - some labels off polygons
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
       fill = "Management Rank") +
  theme(plot.title = element_text(hjust = 0.5), axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.background = element_rect(
          fill = "lightgrey", size = 0.5, linetype = "solid",
          colour = "darkgrey"))
plot(static_ggmap)

# Clip + mask raster to BC boundary
# stamenbc_crop <- raster::crop(stamenbc, bc_boundary)
