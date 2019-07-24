## ----------------------
## RASTERIZE BEC POLYGONS
library(sf)
library(fasterize)
library(rasterVis)
library(purrr)
library(envreportutils)
library(tidyverse)
library(future)
library(bcmaps)
library(future.apply)
library(envreportutils.internal)
library(raster)
library(dplyr)
library(mapview)
library(bcdata)
library(rmapshaper)

# devtools::install_github("bcgov-c/envreportutils.internal")

# set path to ghostscript executable
envreportutils.internal:::set_ghostscript('path_to_executable')

# Add remote version of bcmaps
# remotes::install_github("bcgov/bcmaps", ref = "future", force = T)

# Not to be used in new version unless needed:
# Summarise total pop estimate per management unit
by_gbpu <- grizzlypop_raw %>%
  group_by(GBPU) %>%
  summarise(POP_ESTIMATE = sum(Estimate),
            Total_Area = sum(Total_Area),
            # Recalculate Density (bears / 1000 km^2)
            POP_DENSITY = round(POP_ESTIMATE / (Total_Area / 1000))) %>%
  rename(gbpu_name = GBPU) %>%
  rename_all(tolower) # Set to lower case
glimpse(by_gbpu)
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

# Map call to replace above loop:
plot_list <- map(gbpu_list, ~ {
  data <- filter(mort_summary, gbpu_name == .x)
  Mortality(data, .x)
})

# name list
names(plot_list) <- gbpu_list

# Check result
plot_list[["Valhalla"]]

# Save svgs to plot list
iwalk(plot_list, ~ save_svg_px(.x, file = paste0("out/", .y, ".svg"),
                               width = 600, height = 300))
# Save plots to file
saveRDS(plot_list, file = "out/grizz_plotlist.rds")
