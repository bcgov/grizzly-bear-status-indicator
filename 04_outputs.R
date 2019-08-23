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
library(tidyverse)
library(dplyr)

if (!exists("grizzdata_full")) load("data/grizzdata_full.rds")

# create static summary plots
sdata <- grizzdata_full %>%
  group_by(threat_class) %>%
  select(-c(geometry)) %>%
  summarize(count = n()) %>%
  filter(!is.na(threat_class))

sdata <- as.data.frame(sdata)
sdata <- sdata %>% select(-geometry)

#pal1 <- colorFactor(palette = 'viridis', grizzdata_full$threat_class,
#                    ordered = TRUE, na.color = "#808080", reverse = TRUE)

palv <- c("Negligible" = "#440154FF", "Low" = "#3B528BFF" ,
          "Medium" = "#21908CFF", "High" = "#5DC863FF" ,
          "Very High" = "#FDE725FF", "NA" = "#808080")

palvr <- c("M5"= "#440154FF",  "M4" ="#3B528BFF", "M3" ="#21908CFF",
           "M2" ="#5DC863FF", "M1" ="#FDE725FF", "NA" = "#808080")
palvrn <- c( "5" = "#440154FF",  "4" ="#3B528BFF", "3" ="#21908CFF",
           "2" ="#5DC863FF", "1" ="#FDE725FF", "NA" = "#808080")

colour_table <- tribble(
  ~calcsrank, ~plot_col,
  "M1", "#FDE725FF",
  "M2", "#5DC863FF",
  "M3", "#21908CFF",
  "M4", "#3B528BFF",
  "M5", "#440154FF"
)



overall_threat_plot <-
  ggplot(sdata, aes(y = count, x = threat_class)) +
  geom_bar(stat = "identity", aes(fill = as.factor(threat_class)), show.legend = FALSE) +
  scale_x_discrete(limits = c("Negligible", "Low", "Medium", "High", "Very High"))+
  scale_fill_manual(values = palv)+
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

if (!exists("total_threats")) load("dataviz/leaflet/threat_plots/total_threats.rds")

tdata <- total_threats %>%
  group_by(threat, ranking) %>%
  summarise(count = length(gbpu_name))

tdata$ranking <- factor(tdata$ranking, ordered = TRUE,
                                levels = c("Negligible", "Low", "Medium", "High", "Very High"))
threat_sum_plot <-
  ggplot(tdata, aes(y = count, x = threat,
                              fill = ranking)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = palv) +
  scale_y_continuous(limits = c(0,55), breaks = seq(0,50,10))+
  ggtitle("Estimated Impact of Threat Catergory") +
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


# output radar plots for all gbpu units for static version
# does not include extirpated GBPU

cc_data <- grizz.df %>%
  mutate(trend_adj = as.numeric(trend) * -1) %>%
  select(gbpu_name, calcsrank, trend_adj, popiso_rank_adj, threat_rank_adj) %>%
  gather("metric", "score", -gbpu_name, -calcsrank, trend_adj, popiso_rank_adj, threat_rank_adj) %>%
  mutate(max_val = case_when(metric == "trend_adj" ~ 1, metric == "popiso_rank_adj" ~ 4, metric == "threat_rank_adj" ~ 2),
         label = case_when(metric == "trend_adj" ~ "Trend", metric == "popiso_rank_adj" ~ "Population/\nIsolation", metric == "threat_rank_adj" ~ "Threat"),
         label_pos= case_when(metric == "trend_adj" ~ 2.2, metric == "popiso_rank_adj" ~ 5.5, metric == "threat_rank_adj" ~ 2.8)
  ) %>%
  left_join(colour_table) %>%
  filter(!is.na(calcsrank))


coord_radar <- function (theta = "x", start = 0, direction = 1, clip = "on") {
  theta <- match.arg(theta, c("x", "y"))
  r <- if (theta == "x") "y" else "x"
  ggproto("CordRadar", CoordPolar, theta = theta, r = r, start = start,
          direction = sign(direction),
          clip = clip,
          is_linear = function(coord) TRUE)
}

# Create radar plot list
rad_plot <- ggplot(cc_data, aes(x = metric, y = score)) +
    facet_wrap(~ gbpu_name) +
    geom_polygon(aes(group = NA, fill = as.numeric(str_extract(calcsrank, "\\d")),
                      colour = as.numeric(str_extract(calcsrank, "\\d"))),
                  alpha = 0.6, size = 2) +
   geom_errorbar(aes(x = metric, ymin = 0, ymax = max_val),
                  width = 0.1, colour = "grey40") +
    scale_colour_viridis_c(direction = -1, guide = "none") +
    scale_fill_viridis_c(direction = -1, guide = "none") +
    #scale_fill_manual(values = palvr) +
    #scale_y_continuous(expand = expand_scale(mult = 0, add = 0)) +
    #geom_text(aes(x = metric, y = label_pos, label = label),
    #          colour = "grey40") +
    #geom_text(aes(label = calcsrank, colour = as.numeric(str_extract(calcsrank, "\\d"))),
    #          x = 0.5, y = 2, size = 4) +
    geom_text(aes(label = gbpu_name),
              x = 0.5, y = 4.5, size = 2, colour = "grey40") +
    coord_radar(clip = "off") +
    theme_void() +
    theme(plot.margin = unit(c(0,0,0,0), "lines"), strip.text = element_blank())

rad_plot

# add a legend and overall plot to explain positions.



## Printing plots for web in SVG formats (and PNG)
svg_px("./print_ver/radar_plot.svg", width = 500, height = 400)
plot(rad_plot)
dev.off()

png_retina(filename = "./print_ver/radar_plot.png", width = 500, height = 400,
           units = "px", type = "cairo-png", antialias = "default")
plot(rad_plot)
dev.off()


## ----------------------------------------------------------------------------
## STATIC MAPPING
## ----------------------------------------------------------------------------
staticmap <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = calcsrank), color = "white", size = 0.1) +
  labs(title = "Conservation Concern of Grizzly Bear Population Units in BC",
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


if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE)
save(threat_sum_plot, overall_threat_plot, staticmap,
     file = "tmp/plots.RData")
