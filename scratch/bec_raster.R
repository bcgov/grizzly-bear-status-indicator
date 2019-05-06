## ----------------------
## RASTERIZE BEC POLYGONS
library(sf)
library(fasterize)
library(rasterVis)
library(purrr)
library(envreportutils)

## Import grizzly BEI polygons (2019) as sf ---------------------------
habclass <- st_read("C:/dev/grizzly-bear-status-indicator/habclass.shp")
plot(st_geometry(habclass))

## Simplify BEI polygons ----------------------------------------------
# habclass_simp <- ms_simplify(habclass, keep = 0.05, sys = TRUE)
# saveRDS(habclass_simp, file = "habclass_simp.rds")
habclass_simp <- readRDS("habclass_simp.rds")
plot(habclass_simp[14])

## Rename values to NAs
habclass_simp$RATING <- as.character(habclass_simp$RATING)
habclass_simp$RATING[habclass_simp$RATING == "66"] <- "NA"
habclass_simp$RATING[habclass_simp$RATING == "99"] <- "NA"
habclass_simp$RATING <- as.factor(habclass_simp$RATING) # to factor

## Add gbpu polygons --------------------------------------------------
gbpu_2015 <- st_read("C:/dev/grizzly-bear-status-indicator/gbpu_2015.shp")

## Create value with population field
population <- "POPULATION"

# extract Cranberry
cran <- gbpu_2015 %>% filter(POPULATION == "Cranberry")
tweed <- gbpu_2015 %>% filter(POPULATION == "Tweedsmuir")

# Rasterize whole habitat class
whole <- raster(habclass_simp, res = 90)
whole <- fasterize(habclass_simp, whole, field = "RATING")
whole <- as.factor(whole)
plot(whole)
rat1 <- levels(whole)[[1]]
rat1[["rating"]] <- c("1","2","3","4","5","6","NA")
levels(whole) <- rat1 # Add RAT to raster
# WriteRaster(whole, filename = file.path(out, "habclass_rast.grd"))
whole

# Crop raster to Cranberry GBPU sf
cran_rast <- raster::crop(whole, cran)
cran_mask <- raster::mask(cran_rast, cran)
plot(cran_mask)

tweed_rast <- raster::crop(whole, tweed)
tweed_mask <- raster::mask(tweed_rast, tweed)
plot(tweed_mask)
levelplot(tweed_mask)

# Plot categorical raster -- trellis
beczones <- levelplot(whole)
plot(beczones)

gbpu_rasts <- raster_by_poly(whole, gbpu_2015, population)
?raster_by_poly
class(gbpu_2015)

strata <- bcmaps::ecoregions()
strata
gbpu_2015
gbpu_2015 <- st_geometry(gbpu_2015)
gbpu_2015 <- st_transform(gbpu_2015)
