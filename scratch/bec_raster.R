## ----------------------
## RASTERIZE BEC POLYGONS
## ----------------------
library(sf)
library(fasterize)
library(rasterVis)

# Import grizzly BEI polygons (2019) as sf
habclass <- st_read("C:/dev/grizzly-bear-status-indicator/habclass.shp")
plot(st_geometry(habclass))
levels(habclass_simp)

# Simplify BEI polygons
# habclass_simp <- ms_simplify(habclass, keep = 0.05, sys = TRUE)
# saveRDS(habclass_simp, file = "habclass_simp.rds")
habclass_simp <- readRDS("habclass_simp.rds")
plot(habclass_simp[9])

# Extract Chilcoltin
chic <- habclass_simp %>% filter(ES_Name == "Chilcotin Plateau")
gulf <- habclass_simp %>% filter(ES_Name == "Southern Gulf Islands")
plot(chic[9])
plot(gulf[9])

# add gbpu polygons
gbpu_2015 <- st_read("C:/dev/grizzly-bear-status-indicator/gbpu_2015.shp")

# extract Cranberry
cran <- gbpu_2015 %>% filter(POPULATION == "Cranberry")
cran <- as(cran, 'Spatial')

# Rasterize
r <- raster(gulf, res = 50)
r <- fasterize(gulf, r, field = "BECLABEL")
plot(r)

# Rasterize whole habitat class
whole <- raster(habclass_simp, res = 90)
whole <- fasterize(habclass_simp, whole, field = "ZONE")
whole <- as.factor(whole)
plot(whole, legend = T)
whole <- ratify(whole)

rat <- levels(whole)[[1]]
rat[["ecozone"]] <- c("BAFA","BG","BWBS","CDF","CMA","CWH","ESSF","ICH","IDF",
"IMA","MH","MS","PP","SBPS","SBS","SWB")
levels(whole) <- rat
whole <- as.factor(whole)

beczones <- levelplot(whole)
plot(beczones)

# Crop raster to Cranberry GBPU sf
cran_rast <- raster::crop(whole, cran)
cran_mask <- raster::mask(cran_rast, cran)
plot(cran_mask, legend = T)
plot(cran, add = T)
