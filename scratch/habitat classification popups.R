
## Simplify BEI polygons ----------------------------------------------
habclass_simp <- ms_simplify(habclass, keep = 0.05, sys = TRUE)
# saveRDS(habclass_simp, file = "habclass_simp.rds")
# habclass_simp <- readRDS("data/habclass_simp.rds")
# plot(habclass_simp)
# summary(habclass_simp)

## Rename values to NAs -----
# habclass_simp$RATING[habclass_simp$RATING == 66] <- "Never Occupied"
# habclass_simp$RATING[habclass_simp$RATING == 99] <- "Extirpated"
# habclass_simp$RATING <- as.double(habclass_simp$RATING)

# Rasterize whole habitat class
library(raster)
library(fasterize)

whole <- raster(habclass_simp, res = 90)
whole <- fasterize(habclass_simp, whole, field = "RATING")
# whole <- projectExtent(whole, crs = grizzdata_full)
# whole <- as.factor(whole)
# rat1 <- levels(whole)[[1]]
# rat1[["rating"]] <- c("1","2","3","4","5","6","NA")
# levels(whole) <- rat1 # Add RAT to raster
# WriteRaster(whole, filename = file.path(out, "habclass_rast.grd"))
plot(whole)

## Create value with population field
gbpu_name <- "gbpu_name"

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
popups <-  leafpop::popupGraph(plot_list, type = "png", width = 400,
                               height = 300)
saveRDS(popups, "out/raster_popups.rds")
popup_options <-  popupOptions(maxWidth = "100%", autoPan = TRUE,
                               keepInView = TRUE,
                               closeOnClick = TRUE,
                               autoPanPaddingTopLeft = c(120, 10),
                               autoPanPaddingBottomRight = c(120,10))

# Save pngs of plots:
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
