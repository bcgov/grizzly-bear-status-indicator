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

# Add conservation status popups?






## ----------------------------------------------------------------------------
## THREAT POPUP MAPPING
## ----------------------------------------------------------------------------
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

saveRDS(total_threats, file = "data/total_threats.rds")

# Create list of GBPU
gbpu_list <- unique(grizzdata_full$gbpu_name)

# Create list for plots
threat_plot_list <- vector(length = length(gbpu_list), mode = "list")
names(threat_plot_list) <- gbpu_list

# Create plotting function
Threat_Plots <- function(data, name) {
  make_plot <- ggplot(data, aes(x = threat, y = ranking,
                                fill = ranking)) +
    geom_bar(stat = "identity") + # Add bar for each threat variable
    scale_fill_brewer("Threat Ranking", palette = "Set2") +
    labs(x = "Threat", y = "Threat Ranking",
         fill = "Ranking") + # Legend text
    ggtitle(name)+
    theme(legend.position = "none")
    theme_soe() + theme(plot.title = element_text(hjust = 0.5), # Centre title
                       legend.position = "none",
                        plot.caption = element_text(hjust = 0))  # L-align caption
 # scale_y_discrete (limits = c("Negligible", "Low", "Medium", "High", "Very High"))
 # This line causes problems with no data sites (ie Central Interior)

  make_plot + coord_flip()
}

#ifelse(!dir.exists(file.path("out/")), dir.create(file.path("out/")), FALSE)

#n <- gbpu_list[56]

# Create ggplot graph loop
plots <- for (n in gbpu_list) {
  print(n)
  data <- filter(total_threats, gbpu_name == n)
  p <- Threat_Plots(data, n)
  threat_plot_list[[n]] <- p
  ggsave(p, file = paste0("out/", n, ".svg"))
}

# Check result
threat_plot_list[["Valhalla"]]

# Svg function
save_svg <- function(x, fname, ...) {
  svg_px(file = fname, ...)
  plot(x)
  dev.off()
 }

# Save svgs to plot list
iwalk(threat_plot_list, ~ save_svg(.x, fname = paste0("out/", .y, ".svg"),
                            width = 250, height = 250))

# Save plots to file
# saveRDS(threat_plot_list, file = "out/threat_plotlist.rds")

threat_popups <-  leafpop::popupGraph(threat_plot_list, type = "svg")#,
                                      #width = 250, height = 250)

saveRDS(threat_popups, "out/threat_popups.rds")
