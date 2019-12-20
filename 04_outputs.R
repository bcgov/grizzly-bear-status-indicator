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
library(here)
library(readr)
library(dplyr)
library(rmapshaper)
library(bcmaps)
library(ggplot2)
library(sf)
library(purrr)
library(forcats)

if (!exists("grizzdata_full")) load("data/grizzdata_full.rds")

# set up colour pallett for figures:

palv <- c("Negligible" = "#440154FF", "Low" = "#3B528BFF" ,
          "Medium" = "#21908CFF", "High" = "#5DC863FF" ,
          "Very High" = "#FDE725FF", "NA" = "#808080")

palvn <- c("M5" = "#440154FF", "M4" = "#3B528BFF" ,
          "M3" = "#21908CFF", "M2" = "#5DC863FF" ,
          "M1" = "#FDE725FF", "NA" = "#808080")

# create static summary plots
sdata <- grizzdata_full %>%
  group_by(threat_class) %>%
  select(-c(geometry)) %>%
  summarize(count = n()) %>%
  filter(!is.na(threat_class))

sdata <- as.data.frame(sdata)
sdata <- sdata %>% select(-geometry)

overall_threat_plot <-
  ggplot(sdata, aes(y = count, x = threat_class)) +
  geom_bar(stat = "identity", aes(fill = as.factor(threat_class)), show.legend = FALSE) +
  scale_x_discrete(limits = c("Negligible", "Low", "Medium", "High", "Very High")) +
  scale_fill_manual(values = palv) +
  geom_text(aes(label=count), vjust=0.5, hjust = 2) +
  coord_flip() +
  labs(y = "Number of Grizzly Bear Population Units (GBPU)", x = "Overall Threat")+
  ggtitle("Overall threat impacts to Grizzly Bear Population Units") +
  theme_soe()

## Printing plots for web in SVG formats (and PNG)

multi_plot <- function(plotdata, filename) {
  svg_px( paste0(filename,".svg"), width = 500, height = 400)
  plot(plotdata)
  dev.off()
  png_retina(paste0(filename,".png"), width = 500, height = 400,
             units = "px", type = "cairo-png", antialias = "default")
  plot(plotdata)
  dev.off()
}

multi_plot(overall_threat_plot, "./print_ver/othreat_plot")


# generate sumary plot per threat

if (!exists("total_threats")) load("dataviz/leaflet/threat_plots/total_threats.rds")

tdata <- total_threats %>%
  group_by(threat, ranking) %>%
  summarise(count = length(gbpu_name))

tdata$ranking <- factor(tdata$ranking, ordered = TRUE,
                                levels = c("Negligible", "Low", "Medium", "High", "Very High"))
threat_sum_plot <-
  ggplot(tdata, aes(y = count, x = threat,fill = ranking)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = palv) +
  scale_y_continuous(limits = c(0,55), breaks = seq(0,50,10))+
  ggtitle("Estimated Impact of Threat Catergory") +
  labs(x = "Threat", y = "Number of Grizzly Bear Population Units (n = 55)",
       fill = "Ranking") +
  guides(fill= guide_legend (reverse = TRUE))+
  coord_flip() +
  theme_soe()

#write out plots
multi_plot(threat_sum_plot, "./print_ver/threat_sum_plot")


# output radar plots for all gbpu units for static version
cc_data <- grizz.df %>%
  mutate(trend_adj = as.numeric(trend) * -1) %>%
  select(gbpu_name, calcsrank, con_stats, trend_adj, popiso_rank_adj, threat_rank_adj) %>%
  gather("metric", "score", -gbpu_name, -calcsrank, -con_stats, trend_adj, popiso_rank_adj, threat_rank_adj) %>%
  mutate(max_val = case_when(metric == "trend_adj" ~ 1, metric == "popiso_rank_adj" ~ 4, metric == "threat_rank_adj" ~ 2),
         label = case_when(metric == "trend_adj" ~ "Trend", metric == "popiso_rank_adj" ~ "Population/\nIsolation", metric == "threat_rank_adj" ~ "Threat"),
         label_pos= case_when(metric == "trend_adj" ~ 2.2, metric == "popiso_rank_adj" ~ 5.5, metric == "threat_rank_adj" ~ 2.8)
  ) %>%
  #left_join(colour_table) %>%
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
    geom_text(aes(label = gbpu_name),
              x = 0.5, y = 4.5, size = 2.5, colour = "grey40") +
    coord_radar(clip = "off") +
    theme_void() +
    theme(plot.margin = unit(c(0,0,0,0), "lines"), strip.text = element_blank())


# create a rad_plot Key
cc_data_name <- cc_data %>%
  filter(gbpu_name == "Taiga")

# Create radar plot list
rad_plot_key <- ggplot(cc_data_name, aes(x = metric, y = score)) +
  geom_errorbar(aes(x = metric, ymin = 0, ymax = max_val),
                width = 0.1, colour = "grey40") +
  geom_text(aes(label = "Key"), colour = "grey40",
                x = 0.5, y = 5, size = 4) +
  geom_text(aes(x = metric, y = label_pos, label = label),
            colour = "grey40", size = 2) +
    coord_radar(clip = "off") +
  theme_void()



## Printing plots for web in SVG formats (and PNG)

svg_px("./print_ver/radar_plot.svg", width = 500, height = 400)
plot(rad_plot)
dev.off()

png_retina(filename = "./print_ver/radar_plot.png", width = 500, height = 400,
           units = "px", type = "cairo-png", antialias = "default")
plot(rad_plot)
dev.off()

png_retina("./print_ver/radar_plot_key.png", width = 100, height = 100,
           units = "px", type = "cairo-png", antialias = "default")
plot(rad_plot_key)
dev.off()



## Static Maps ----------------------------------------------------------------------------

# Map 1: concervation concern
cons_smap <- ggplot(grizzdata_full) +
  geom_sf(data = bc_bound(), fill = NA, color = "grey", size = 0.2) +
  geom_sf(aes(fill = calcsrank), alpha = 0.8) +
  coord_sf(datum = NA) +
  scale_fill_manual(values = palvn, na.value = "light grey",
                    labels = c("Extreme","High","Moderate","Low","Negligible","Extirpated")) +
  labs(fill = "Conservation Ranking") +
  theme_minimal() +
  theme(legend.position = c(0.1, 0.35))


# Map 2: population density map
pop_smap <- ggplot(grizzdata_full)+
  geom_sf(data = bc_bound(), fill = NA, color = "grey", size = 0.2) +
  geom_sf(aes(fill = pop_density)) +
  coord_sf(datum = NA) +
  scale_fill_viridis_c(alpha = 0.9,
                     option = "viridis", direction = 1,
                     na.value = "light grey", trans = "reverse") +
  labs(fill = "Population Density") +
  theme_minimal() +
  guides(colour = guide_legend(reverse = T)) +
  theme(legend.position = c(0.1, 0.35))


# map 3: threat map
threat_smap <- ggplot(grizzdata_full)+
  geom_sf(data = bc_bound(), fill = NA, color = "grey", size = 0.2) +
  geom_sf(aes(fill = threat_class), alpha = 0.8) +
  coord_sf(datum = NA) +
  scale_fill_manual(values = palv, na.value = "light grey",
                    labels = c("Very High","High","Medium","Low","Negligible","Extirpated")) +
  labs(fill = "Threat Rank", reverse = TRUE) +
  theme_minimal() +
  theme(legend.position = c(0.1, 0.35))

# map 4 : mortality map
mort_splot <- ggplot(mort_sum, aes(y = count, x = hunt_year, fill = kill_code)) +
  facet_wrap(~gbpu_name) +
  geom_bar(stat = "identity") + # Add bar for each threat variable
  scale_fill_manual(values = pal_mort) +
  labs(x = "Year", y = "Number of Grizzlies killed")+
  scale_x_continuous(limits = c(1976, 2018), breaks = seq(1970,2018,20)) +
  scale_y_continuous(limits = c(0, 50), breaks = seq(0,50,25)) +
  theme(strip.text.x = element_text(size = 6),
        axis.text=element_text(size=6))

mort_splot


# save output maps

multi_plot(cons_smap, "./print_ver/cons_splot")

multi_plot(pop_smap, "./print_ver/pop_splot")

multi_plot(threat_smap, "./print_ver/threat_splot")

#multi_plot(mort_splot, "./print_ver/mort_splot")


svg_px("./print_ver/mort_splot.svg", width = 550, height = 700)
plot(mort_splot)
dev.off()

png_retina(filename = "./print_ver/mort_splot.png", width = 550, height = 800,
           units = "px", type = "cairo-png", antialias = "default")
plot(mort_splot)
dev.off()

