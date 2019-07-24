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

# Create 'out' directory
figsOutDir <- "out"

threat_calc <- threat_calc %>%
  select(gbpu_name, ends_with("calc")) %>%
  rename(
  "Residential" = residentialcalc,
  "Agriculture" = agriculturecalc,
  "Energy" = energycalc,
  "Transportation" = transportationcalc,
  "Biouse" = biousecalc,
  "Human_Intrusion" = humanintrusioncalc,
  "Climate_Change" = climatechangecalc
)

total_threats <- gather(threat_calc, key = "threat", value = "ranking",
                        Residential, Agriculture, Energy, Transportation,
                        Biouse, Human_Intrusion, Climate_Change) %>%
  select(gbpu_name, threat, ranking)

total_threats$ranking <- factor(total_threats$ranking, ordered = TRUE,
                                levels = c("Negligible", "Low", "Medium", "High", "Very High"))

# Create list of GBPU
gbpu_list <- unique(grizzdata_full$gbpu_name)

# Create list for plots
threat_plot_list <- vector(length = length(gbpu_list), mode = "list")
names(threat_plot_list) <- gbpu_list

# Create plotting function
Threat_Plots <- function(data, name) {
  # Create plot for a single GBPU
  make_plot <- ggplot(data, aes(x = threat, y = ranking,
                                fill = ranking)) +
    geom_bar(stat = "identity") + # Add bar for each threat variable
    scale_fill_brewer("Threat Ranking", palette = "Set2") +
    labs(x = "Threat", y = "Threat Ranking",
         fill = "Ranking") + # Legend text
    ggtitle(paste("Threat Ranking for the "
                  , name
                  , " Population Unit"
                  ,sep = "")) +
    theme_soe() + theme(plot.title = element_text(hjust = 0.5), # Centre title
                        legend.position = "bottom",
                        plot.caption = element_text(hjust = 0)) # L-align caption
  make_plot
}

# Create ggplot graph loop
plots <- for (n in gbpu_list) {
  print(n)
  data <- filter(total_threats, gbpu_name == n)
  # print(head(data))
  p <- Threat_Plots(data, n)
  threat_plot_list[[n]] <- p
  ggsave(p, file = paste0("out/", n, ".svg"))
}

# Check result
threat_plot_list[["Valhalla"]]

# Svg function
# save_svg <- function(x, fname, ...) {
#  svg_px(file = fname, ...)
#  plot(x)
#  dev.off()
# }

# Save svgs to plot list
# iwalk(threat_plot_list, ~ save_svg(.x, fname = paste0("out/", .y, ".svg"),
#                            width = 600, height = 300))

# Save plots to file
# saveRDS(threat_plot_list, file = "out/threat_plotlist.rds")

threat_popups <-  leafpop::popupGraph(threat_plot_list, type = "svg")

# width = 500, height = 300
# names(threat_popups) <- gbpu_list

saveRDS(threat_popups, "out/threat_popups.rds")


## ----------------------------------------------------------------------------
## STATIC MAPPING
## ----------------------------------------------------------------------------
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
