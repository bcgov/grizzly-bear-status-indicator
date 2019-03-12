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

# Write directory for plot outputs
dir.create("out", showWarnings = FALSE)

# Create list of GBPU
gbpu_list <- unique(mort_summary$gbpu_name)

# Create list for plots
plot_list <- vector(length = length(gbpu_list), mode = "list")
names(plot_list) <- gbpu_list

# Create plotting function
Mortality <- function(data, name) {
  # Create plot for a single GBPU
  mortality_plot <- ggplot(data, aes(x = hunt_year, y = count,
                                     fill = kill_code)) +
    geom_bar(stat = "identity") + # Add bar for each year w/ fill = kill type
    scale_fill_brewer("Mortality Type", palette = "Set2") +
    scale_x_continuous(breaks=seq(1970, 2017, by = 5)) +
    labs(x = "Year", y = "Number of Grizzly Bears Killed",
         fill = "Mortality Type", caption = caption.text) + # Legend text
    ggtitle(paste("Mortality History for the '"
                  , name
                  , "' Population Unit"
                  , ", 1976-2017"
                  ,sep = "")) +
    theme_soe() + theme(plot.title = element_text(hjust = 0.5), # Centre title
                        legend.position = "bottom",
                        plot.caption = element_text(hjust = 0)) # L-align caption
  mortality_plot
}

# Create ggplot graph loop
plots <- for (n in gbpu_list) {
  print(n)
  data <- filter(mort_summary, gbpu_name == n)
  # print(head(data))
  p <- Mortality(data, n)
  plot_list[[n]] <- p
  ggsave(p, file = paste0("out/", n, ".svg"))
}

# Map call to replace above loop:
plot_list <- map(gbpu_list, ~ {
  data <- filter(mort_summary, gbpu_name == .x)
  Mortality(data, .x)
})
# name list
names(plot_list) <- gbpu_list

# Check result
plot_list[["Valhalla"]]

# Svg function
save_svg <- function(x, fname, ...) {
  svg_px(file = fname, ...)
  plot(x)
  dev.off()
}

# Save svgs to plot list
iwalk(plot_list, ~ save_svg(.x, fname = paste0("out/", .y, ".svg"),
                            width = 600, height = 300))

# Save plots to file
saveRDS(plot_list, file = "out/grizz_plotlist.rds")
