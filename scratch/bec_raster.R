##
## RASTERIZE BEC POLYGONS
##
library(sf)
library(fasterize)

# Import grizzly BEI polygons (2019) as sf
habclass <- st_read("C:/dev/grizzly-bear-status-indicator/habclass.shp")
plot(st_geometry(habclass))

# Simplify BEI polygons
habclass_simp <- ms_simplify(habclass, keep = 0.1, sys = TRUE)
plot(habclass_simp[4])

# Extract Chilcoltin
chic <- habclass %>% filter(ES_Name == "Chilcotin Plateau")
chic_25 <- ms_simplify(chic, keep = 0.25)
gulf <- habclass %>% filter(ES_Name == "Southern Gulf Islands")
gulf_10 <- ms_simplify(gulf, keep = 0.1)
plot(gulf)

# add gbpu polygons
gbpu_2015 <- st_read("C:/dev/grizzly-bear-status-indicator/gbpu_2015.shp")

# extract Cranberry
cran <- gbpu_2015 %>% filter(POPULATION == "Cranberry")

# Rasterize
r <- raster(gulf_10, res = 10)
r <- fasterize(gulf_10, r, field = "RATING")
plot(r)
list(habclass$ES_Name)
