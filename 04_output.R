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

# Create 'out' directory
figsOutDir <- "out"

## Import grizzly BEI polygons (2019) as sf ---------------------------
habclass <- bcdc_get_data(record = 'dba6c78a-1bc1-4d4f-b75c-96b5b0e7fd30',
                          resource = 'd23da745-c8c5-4241-b03d-5654591e117c')
# plot(st_geometry(habclass))

## Simplify BEI polygons ----------------------------------------------
habclass_simp <- ms_simplify(habclass, keep = 0.05, sys = TRUE)
# saveRDS(habclass_simp, file = "habclass_simp.rds")
# habclass_simp <- readRDS("data/habclass_simp.rds")
# plot(habclass_simp)
# summary(habclass_simp)

## Rename values to NAs
# habclass_simp$RATING[habclass_simp$RATING == 66] <- "Never Occupied"
# habclass_simp$RATING[habclass_simp$RATING == 99] <- "Extirpated"
# habclass_simp$RATING <- as.double(habclass_simp$RATING)

## Add gbpu polygons --------------------------------------------------
grizzdata_full <- readRDS("data/grizzdata_full.rds") %>%
  transform_bc_albers()

## Create value with population field
gbpu_name <- "gbpu_name"

# Rasterize whole habitat class
whole <- raster(habclass_simp, res = 90)
whole <- fasterize(habclass_simp, whole, field = "RATING")
# whole <- projectExtent(whole, crs = grizzdata_full)
# whole <- as.factor(whole)
# rat1 <- levels(whole)[[1]]
# rat1[["rating"]] <- c("1","2","3","4","5","6","NA")
# levels(whole) <- rat1 # Add RAT to raster
# WriteRaster(whole, filename = file.path(out, "habclass_rast.grd"))
plot(whole)

## Raster by poly ----------------------------------------
# plan(multiprocess(workers = 4))
gbpu_rasts <- raster_by_poly(whole, grizzdata_full, gbpu_name, parallel = FALSE)

# gbpu_rasts <- c(whole, gbpu_rasts)
# names(gbpu_rasts)[1] <- "Province"
# plot(gbpu_rasts$Province)
saveRDS(gbpu_rasts, file = "out/gbpu_rasts.rds")

# Summary
# plan(multiprocess(workers = 4))
gbpu_rast_summary <- summarize_raster_list(gbpu_rasts, parallel = TRUE) # needed?

## Raster functions
ggmap_gbpu <- function(grizzdata_full) {
  e <- extent(grizzdata_full)
  loc <- c(e[1] - 2, e[3] - 2, e[2] + 2, e[4] + 2)
  get_map(loc, maptype = "terrain")
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
  GPGroups <- filter(grizzdata_full, gbpu_name == .y)
  plotMap <- gbpuRastMaps(.x, title = .y,
                          plot_gmap = FALSE, legend = T)

  # Save in a list
  list(map = plotMap)
})

# Check result
plot_list[["Taiga"]]

# Save to disk
saveRDS(plot_list, file = "out/plot_list.rds")

# Popups for leaflet map
popups <-  leaflet::popupGraph(plot_list, type = "png", width = 500,
                               height = 300)
saveRDS(popups, "out/grizz_popups2.rds")
popup_options <-  popupOptions(maxWidth = "100%", autoPan = TRUE,
                               keepInView = TRUE,
                               closeOnClick = TRUE,
                               autoPanPaddingTopLeft = c(120, 10),
                               autoPanPaddingBottomRight = c(120,10))
# save pngs of plots:
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

