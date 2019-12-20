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

popiso_table <- tribble(
  ~popiso, ~popiso_rank_adj,
  "AA", 4,
  "AB", 4,
  "AC", 4,
  "AD", 3,
  "BA", 4,
  "BB", 1.5,
  "BC", 1,
  "BD", 0.5,
  "CA", 4,
  "CB", 1.5,
  "CC", 1,
  "CD", 0,
  "DA", 3,
  "DB", 1,
  "DC", 0.5,
  "DD", 0,
  "EA", 2,
  "EB", 1,
  "EC", 0.5,
  "ED", 0
)

threat_table <- tribble(
  ~threat_class, ~threat_rank_adj,
  "Very High", 2,
  "High", 1.5,
  "Medium", 1.0,
  "Low", 0,
  "Negligible", 0
)

threat_sub_table <- tribble(
  ~threat_sub, ~threat_sub_name,
  "residential_1a_subtfail", "Urban & Industrial",
  "residential_1b_subtfail", "Human Density",
  "agriculture_2.1_subtfail", "Agriculture",
  "agriculture_2.3b_subtfail", "Livestock Density",
  "energy_3.1_subtfail", "Oil & Gas",
  "energy_3.2_subtfail", "Mining",
  "energy_3.3_subtfail", "Renewable",
  "energy_3all_subtfail", "NA",
  "transport_4.1_subtfail", "Road and Rail",
  "biouse_5.1a_subtfail" , "Female Mortality",
  "biouse_5.1b_subtfail", "Hunting Pressure",
  "biouse_5.3_subtfail", "Forest Age",
  "humanintrusion_6_subtfail", "Recreation use",
  "climatechange_11_subtfail", "Habitat alteration"
)


threat_calc <- threat_calc %>%
  left_join(popiso_table, by = "popiso") %>%
  left_join(threat_table, by = "threat_class") %>%
  mutate(calc_rank_check = 5 - trend*-1 - popiso_rank_adj - threat_rank_adj)


## DATA CLEANING ---------------------------------------------------------

# Find centroid of polygons (for labelling)
# Note: BC Albers CRS used because lat/long not accepted by st_centroid
popcentroid <- st_centroid(st_geometry(gbpu_2018)) %>%
  st_transform(popcentroid, crs = 4326)

# Spatial join
grizzdata_full <- cbind(gbpu_2018,
                        st_coordinates(popcentroid)) # cbind coords and polygons

# Rename lat and lng columns
grizzdata_full <- rename(grizzdata_full, lng = X, lat = Y) %>%
  st_transform(4326) # convert to lat/long

# Rename 'population name' column
grizzdata_full <- grizzdata_full %>%
  rename_all(tolower) %>%
  rename(gbpu_name = population_name)

# Join GBPU polygons (popunits) and threat classification data
grizzdata_full <- left_join(grizzdata_full, threat_calc, by = "gbpu_name")

# Give NA (extirpated) gbpu names
grizzdata_full <- mutate(grizzdata_full,
                         gbpu_name = as.character(gbpu_name),
                         gbpu_name = case_when(
                           grizzly_bear_population_tag == 47 ~ "Northeast",
                           grizzly_bear_population_tag == 48 ~ "Central Interior",
                           grizzly_bear_population_tag == 53 ~ "Lower Mainland",
                           grizzly_bear_population_tag == 81 ~ "Sunshine Coast",
                           TRUE ~ gbpu_name
                         ))

grizzdata_full <- mutate(grizzdata_full,
                         isolation = as.character(popiso),
                         isolation = case_when(
                           str_detect(isolation, "^[A-E]A$") ~ "Totally Isolated",
                           str_detect(isolation, "^[A-E]B$") ~ "Highly Isolated",
                           str_detect(isolation, "^[A-E]C$") ~ "Moderate Isolated",
                           str_detect(isolation, "^[A-E]D$") ~ "Not Isolated")
                         )

grizzdata_full <- mutate(grizzdata_full,
                         con_stats = as.character(calcsrank),
                         con_stats = case_when(
                           str_detect(calcsrank, "1") ~ "Extreme",
                           str_detect(calcsrank, "2") ~ "High",
                           str_detect(calcsrank, "3") ~ "Moderate",
                           str_detect(calcsrank, "4") ~ "Low",
                           str_detect(calcsrank, "5") ~ "Negligible")
)

# Add population density column
grizzdata_full <- mutate(grizzdata_full,
                         area_sq_km = round(as.numeric(set_units(st_area(geometry), km2)), digits = 0),
                         use_area_sq_km = round(as.numeric(h_area_nowice),digits = 0),
                         pop_density = round(as.numeric(gbpu.pop / use_area_sq_km * 1000), digits = 0)
)

# Change threat class column to ordered factor
grizzdata_full <- grizzdata_full %>%
  mutate(threat_class = ifelse(threat_class == "VHigh", "Very High", threat_class))

grizzdata_full$threat_class <- factor(grizzdata_full$threat_class, ordered = TRUE,
                                      levels = c("Very High", "High", "Medium", "Low", "Negligible"))


# Replace NAs in trend column with  "Data Deficient"
grizzdata_full$trend <- grizzdata_full$trend %>% replace_na("Data Deficient")

# Simplify vertices of GBPU polygons
grizzdata_full <- ms_simplify(grizzdata_full, keep = 0.25) # reduce number of vertices

# create mortality data set with matching gbpu_id's
grizz_morts <- grizzdata_full %>%
  select(grizzly_bear_pop_unit_id, grizzly_bear_population_tag,
         gbpu_name, display_name, status, geometry) %>%
  left_join(morts, by = c("grizzly_bear_population_tag" = "GBPU_ID"))

# create subthreat data set with matching gbpu's

threat_sub <- threat_calc %>%
  select(gbpu_name, ends_with("subTFail")) %>%
  pivot_longer(cols = ends_with("subTFail"),
               names_to = "threat_sub",
               values_to = "rank") %>%
  left_join(threat_sub_table) %>%
  mutate(catergory = sub("_.*", "", threat_sub))


# Write grizzly data file to disk
if (!dir.exists("data")) dir.create("data")
saveRDS(grizzdata_full, file = "data/grizzdata_full.rds")
saveRDS(grizz_morts, file = "data/grizz_morts.rds")
