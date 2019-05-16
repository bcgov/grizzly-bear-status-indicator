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

# Add remote version of bcmaps
# remotes::install_github("bcgov/bcmaps", ref = "future", force = T)

## Import grizzly BEI polygons (2019) as sf ---------------------------
habclass <- st_read("C:/dev/grizzly-bear-status-indicator/habclass.shp")
plot(st_geometry(habclass))

## Simplify BEI polygons ----------------------------------------------
# habclass_simp <- ms_simplify(habclass, keep = 0.05, sys = TRUE)
# saveRDS(habclass_simp, file = "habclass_simp.rds")
habclass_simp <- readRDS("habclass_simp.rds")

## Rename values to NAs
habclass_simp$RATING[habclass_simp$RATING == 66] <- NA
habclass_simp$RATING[habclass_simp$RATING == 99] <- NA

## Add gbpu polygons --------------------------------------------------
gbpu_2015 <- st_read("C:/dev/grizzly-bear-status-indicator/gbpu_2015.shp")

# Replace NAs - Needs to be updated with unique identifiers for extirpated
gbpu_2015$POPULATION <- as.character(gbpu_2015$POPULATION)
gbpu_2015$POPULATION[is.na(gbpu_2015$POPULATION)] <- "Extirpated"

## Create value with population field
population <- "POPULATION"

# Rasterize whole habitat class
whole <- raster(habclass_simp, res = 90)
whole <- fasterize(habclass_simp, whole, field = "RATING")
# whole <- as.factor(whole)
# plot(whole)
# rat1 <- levels(whole)[[1]]
# rat1[["rating"]] <- c("1","2","3","4","5","6","NA")
# levels(whole) <- rat1 # Add RAT to raster
# WriteRaster(whole, filename = file.path(out, "habclass_rast.grd"))

# Plot categorical raster -- trellis
beczones <- levelplot(gbpu_rasts)
plot(beczones)

## Raster by poly ----------------------------------------
gbpu_rasts <- raster_by_poly(whole, gbpu_2015, population)
# gbpu_rasts <- c(whole, gbpu_rasts)
names(gbpu_rasts)[1] <- "Province"
plot(gbpu_rasts$Province)
saveRDS(gbpu_rasts, file = "out/gbpu_rasts.rds")

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
  labs(fill = "") +
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
gc()

figsOutDir <- "c:/dev/grizzly-bear-status-indicator/out"

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

memory.limit(size = 9000)
walk(plot_list, ~ {
  plot(.x$map)
})

iwalk(plot_list, ~ png_retina(.x, filename = paste0("out/", .y, ".png"),
                              width = 600, height = 300, units = "px", type = "windows"))
iwalk(plot_list, ~ save_svg_px(.x, file = paste0("out/", .y, ".svg"),
                               width = 600, height = 300))
