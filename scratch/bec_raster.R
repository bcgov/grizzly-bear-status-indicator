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

envreportutils.internal:::set_ghostscript('path_to_executable')
devtools::install_github("bcgov-c/envreportutils.internal")

# Add remote version of bcmaps
# remotes::install_github("bcgov/bcmaps", ref = "future", force = T)

# Create -out directory
figsOutDir <- "c:/dev/grizzly-bear-status-indicator/out"

## Import grizzly BEI polygons (2019) as sf ---------------------------
habclass <- st_read("C:/dev/grizzly-bear-status-indicator/data/habclass.shp")
plot(st_geometry(habclass))

## Simplify BEI polygons ----------------------------------------------
habclass_simp <- ms_simplify(habclass, keep = 0.05, sys = TRUE)
# saveRDS(habclass_simp, file = "habclass_simp.rds")
habclass_simp <- readRDS("data/habclass_simp.rds")
plot(habclass_simp)
summary(habclass_simp)

## Rename values to NAs
# habclass_simp$RATING[habclass_simp$RATING == 66] <- "Never Occupied"
# habclass_simp$RATING[habclass_simp$RATING == 99] <- "Extirpated"

## Add gbpu polygons --------------------------------------------------
grizzdata_full <- readRDS("data/grizzdata_full.rds")
class(grizzdata_full)

## Create value with population field
gbpu_name <- "gbpu_name"

# Rasterize whole habitat class
whole <- raster(habclass_simp, res = 90)
whole <- fasterize(habclass_simp, whole, field = "RATING")
# whole <- as.factor(whole)
plot(whole)
# rat1 <- levels(whole)[[1]]
# rat1[["rating"]] <- c("1","2","3","4","5","6","NA")
# levels(whole) <- rat1 # Add RAT to raster
# WriteRaster(whole, filename = file.path(out, "habclass_rast.grd"))

## Raster by poly ----------------------------------------
gbpu_rasts <- raster_by_poly(whole, grizzdata_full, gbpu_name)
# gbpu_rasts <- c(whole, gbpu_rasts)
# names(gbpu_rasts)[1] <- "Province"
# plot(gbpu_rasts$Province)
saveRDS(gbpu_rasts, file = "out/gbpu_rasts2.rds")

# Summary
gbpu_rast_summary <- summarize_raster_list(gbpu_rasts)

## Raster functions
ggmap_gbpu <- function(gbpu_2015) {
  e <- extent(gbpu_2015)
  loc <- c(e[1] - 2, e[3] - 2, e[2] + 2, e[4] + 2)
  get_map(loc, maptype = "satellite")
}

gbpuRastMaps <- function(dat, title = "", plot_gmap = F,
                         legend = T, max_px = 1000000) {
  if (plot_gmap) {
    dat <- projectRaster(dat, crs = CRS("+proj=longlat +datum=WGS84"))
    gmap <- ggmap_gbpu(dat)
    gg_start <- ggmap(gmap) + rasterVis::gplot(dat, maxpixels = max_px)
    ext <- extent(dat)
    coords <- coord_cartesian(xlim = c(ext@xmin, ext@xmax),
                              ylim = c(ext@ymin, ext@ymax),
                              expand = TRUE)
  } else {
  coords <- coord_fixed()
  gg_start <- rasterVis::gplot(dat, maxpixels = max_px)
  }
  gg_start +
  geom_raster(aes(fill=factor(value)), alpha=0.8) +
  coords +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0)) +
  labs(fill = "Habitat Suitability Rank") +
  theme_minimal() +
  theme(
    axis.text=element_blank(),
    axis.title=element_blank(),
    legend.position=ifelse(legend, "bottom", "none"),
    panel.grid = element_blank()
  )
}

# Generate plots
plot_list <- imap(gbpu_rasts, ~ {
  print(.y)
# Graph functions
  GPGroups <- filter(gbpu_2015, POPULATION == .y)
  plotMap <- gbpuRastMaps(.x, title = .y,
                          plot_gmap = FALSE, legend = FALSE)

  # Save in a list
  list(map = plotMap)
})

# Check result
plot_list[["Taiga"]]

# Save to disk
saveRDS(plot_list, file = "out/plot_list.rds")

#save pngs of plots:
for (n in names(plot_list)) {
  print(n)
  map <- plot_list[[n]]$map
  map_fname <- file.path(figsOutDir, paste0(n, "_map.png"))
  png_retina(filename = map_fname, width = 500, height = 500, units = "px",
             type = "windows")
  plot(map)
  dev.off()
}

# Walk loops over list, but doesn't return anything to the environment
walk(plot_list, ~ {
  plot(.x$map)
})
