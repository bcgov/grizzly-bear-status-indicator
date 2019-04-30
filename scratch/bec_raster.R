## ----------------------
## RASTERIZE BEC POLYGONS
## ----------------------
library(sf)
library(fasterize)
library(rasterVis)
library(purrr)

## Import grizzly BEI polygons (2019) as sf ---------------------------
habclass <- st_read("C:/dev/grizzly-bear-status-indicator/habclass.shp")
plot(st_geometry(habclass))

## Simplify BEI polygons ----------------------------------------------
# habclass_simp <- ms_simplify(habclass, keep = 0.05, sys = TRUE)
# saveRDS(habclass_simp, file = "habclass_simp.rds")
habclass_simp <- readRDS("habclass_simp.rds")

## Add gbpu polygons --------------------------------------------------
gbpu_2015 <- st_read("C:/dev/grizzly-bear-status-indicator/gbpu_2015.shp")
## Create list of gbpu polys
gbpu_list <- unique(gbpu_2015$POPULATION)

# extract Cranberry
cran <- gbpu_2015 %>% filter(POPULATION == "Cranberry")
cran <- as(cran, 'Spatial')

# Rasterize whole habitat class
whole <- raster(habclass_simp, res = 90)
whole <- fasterize(habclass_simp, whole, field = "ZONE")
whole <- as.factor(whole)
rat1 <- levels(whole)[[1]]
rat1[["ecozone"]] <- c("BAFA","BG","BWBS","CDF","CMA","CWH","ESSF","ICH","IDF",
                      "IMA","MH","MS","PP","SBPS","SBS","SWB")
levels(whole) <- rat1

# plot
plot(whole, legend = T)
plot(cran, add = T)

# Crop raster to Cranberry GBPU sf
cran_rast <- raster::crop(whole, cran)
cran_mask <- raster::mask(cran_rast, cran)
plot(cran_mask)
plot(cran, add = T)

# Convert to categorical raster
cran_mask <- ratify(cran_mask)
rat2 <- levels(cran_mask)[[1]]
cran_mask

beczones <- levelplot(cran_mask)
plot(beczones)



