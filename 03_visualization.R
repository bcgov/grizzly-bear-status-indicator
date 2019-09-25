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

if (!exists("dataviz/leaflet/concern_plots/"))
dir.create("dataviz/leaflet/concern_plots/", showWarnings = FALSE)
dir.create("dataviz/leaflet/threat_plots/", showWarnings = FALSE)


# Create list of GBPU
gbpu_list <- unique(grizzdata_full$gbpu_name)

# create the colour pallet for all figures
palv <- c("Negligible" = "#440154FF", "Low" = "#3B528BFF" ,
          "Medium" = "#21908CFF", "High" = "#5DC863FF" ,
          "Very High" = "#FDE725FF", "NA" = "#808080")

#mrank_palette <- c(
#  "M1" = "#FDE725FF" ,
#  "M2" = "#5DC863FF",
#  "M3" = "#21908CFF",
#  "M4" = "#3B528BFF" ,
#  "M5" = "#440154FF",
#  "NA" = "#808080"
#)

# Create Conservation Concern Popup Plots ---------------------------------
grizz.df <- as.data.frame(grizzdata_full)

cc_data <- grizz.df %>%
  mutate(trend_adj = as.numeric(trend) * -1) %>%
  select(gbpu_name, calcsrank, trend_adj, popiso_rank_adj, threat_rank_adj, con_stats) %>%
  gather("metric", "score", -gbpu_name, -calcsrank, -con_stats, trend_adj, popiso_rank_adj, threat_rank_adj) %>%
  mutate(max_val = case_when(metric == "trend_adj" ~ 1, metric == "popiso_rank_adj" ~ 4, metric == "threat_rank_adj" ~ 2),
         label = case_when(metric == "trend_adj" ~ "Trend", metric == "popiso_rank_adj" ~ "Population/\nIsolation", metric == "threat_rank_adj" ~ "Threat"),
         label_pos= case_when(metric == "trend_adj" ~ 2.2, metric == "popiso_rank_adj" ~ 5.5, metric == "threat_rank_adj" ~ 2.8)
  )

coord_radar <- function (theta = "x", start = 0, direction = 1, clip = "on") {
  theta <- match.arg(theta, c("x", "y"))
  r <- if (theta == "x") "y" else "x"
  ggproto("CordRadar", CoordPolar, theta = theta, r = r, start = start,
          direction = sign(direction),
          clip = clip,
          is_linear = function(coord) TRUE)
}

# Create radar plot list
radar_plot_list <- vector(length = length(gbpu_list), mode = "list")
names(radar_plot_list) <- gbpu_list


Radar_Plots <- function(data, name) {
  p <- ggplot(data, aes(x = metric, y = score)) +
    geom_polygon(aes(group = NA,
                     fill = con_stats,
                     colour = con_stats),
                 alpha = 0.7, size = 4) +
    geom_errorbar(aes(x = metric, ymin = 0, ymax = max_val),
                  width = 0.1, colour = "grey40", size = 1.5) +
    scale_colour_manual(guide = "none",
                           values = palv) +
    scale_fill_manual(guide = "none",
                         values = palv) +
    geom_text(aes(x = metric, y = label_pos, label = label),
              colour = "grey40", size = 6) +
    # geom_text(aes(label = calcsrank), colour = "grey40",
    #          x = 0.5, y = 2, size = 12) +
    coord_radar(clip = "off") +
    theme_void() +
    theme(strip.text = element_blank(),
          plot.margin = unit(c(-4, -6, -6, -13), "cm"))
 p

}

# Create ggplot graph loop
plots <- for (n in gbpu_list) {
  print(n)
  data <- filter(cc_data, gbpu_name == n)
  if(length(data$gbpu_name) == 0) {
    p = NA
  } else {
  p <- Radar_Plots(data, n)
  ggsave(p, file = paste0("dataviz/leaflet/concern_plots/", n, ".svg"),
         width = unit(6, "in"), height = unit(5, "in"))

}
  radar_plot_list[[n]] <- p

}


# Svg function
#save_svg <- function(x, fname, ...) {
#  svg_px(file = fname, ...)
#  plot(x)
#  dev.off()
#}

# Save svgs to plot list
#iwalk(radar_plot_list, ~ save_svg(.x, fname = paste0("dataviz/leaflet/concern_plots/", .y, ".svg"),
#                                   width = 250, height = 250))

# Save plots to file
#saveRDS(radar_plot_list, file = "dataviz/leaflet/concern_plots/radar_plotlist.rds")

# create popup and save
#concern_popups <-  leafpop::popupGraph(radar_plot_list, type = "svg")
#saveRDS(concern_popups, "dataviz/leaflet/concern_plots/concern_popups.rds")

## ----------------------------------------------------------------------------
## THREAT POPUP MAPPING
## ----------------------------------------------------------------------------

threat_calc <- threat_calc %>%
  select(gbpu_name, ends_with("calc")) %>%
  rename(
  "Residential" = residentialcalc,
  "Agriculture" = agriculturecalc,
  "Energy" = energycalc,
  "Transportation" = transportationcalc,
  "Biological Use" = biousecalc,
  "Human Intrusion" = humanintrusioncalc,
  "Climate Change" = climatechangecalc
)

total_threats <- gather(threat_calc, key = "threat", value = "ranking",
                        Residential, Agriculture, Energy, Transportation,
                        'Biological Use', 'Human Intrusion', 'Climate Change') %>%
  select(gbpu_name, threat, ranking)

total_threats$ranking <- factor(total_threats$ranking, ordered = TRUE,
                                levels = c("Negligible", "Low", "Medium", "High", "Very High"))

saveRDS(total_threats, file = "dataviz/leaflet/threat_plots/total_threats.rds")

# Create list for plots
threat_plot_list <- vector(length = length(gbpu_list), mode = "list")
names(threat_plot_list) <- gbpu_list

# Create plotting function
Threat_Plots <- function(data, name) {
  make_plot <- ggplot(data, aes(x = threat, y = ranking,
                                fill = ranking, alpha = 0.95)) +
    geom_bar(stat = "identity") + # Add bar for each threat variable
    scale_fill_manual(values = palv) +
    labs(x = "Threat", y = "Threat Ranking",
         fill = "Ranking") +
    ggtitle(name) +
    theme(legend.position = "none") +
    theme_soe() + theme(plot.title = element_text(hjust = 0.5), # Centre title
                       legend.position = "none",
                      plot.caption = element_text(hjust = 0)) +  # L-align caption
   scale_y_discrete(limits = c("Negligible", "Low", "Medium", "High"),
                    drop = FALSE, na.translate = FALSE)
  make_plot + coord_flip()

}

# Create ggplot graph loop
plots <- for (n in gbpu_list) {
  print(n)
  data <- filter(total_threats, gbpu_name == n)
  if(length(data$gbpu_name) == 0) {
    p = NA
  } else {
  p <- Threat_Plots(data, n)
  ggsave(p, file = paste0("dataviz/leaflet/threat_plots/", n, ".svg"))
  }
  threat_plot_list[[n]] <- p
}


# Save svgs to plot list id leaflet folder
#iwalk(threat_plot_list, ~ save_svg(.x, fname = paste0("dataviz/leaflet/threat_plots/", .y, ".svg"),
#                            width = 400, height = 300))

