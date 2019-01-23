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

# Assign colour palette
pal <- c("Extirpated" = "firebrick2", "Threatened" = "yellow1", "Viable" = "forestgreen")

# Build basic static map for grizzly popunits/status
staticmap <- ggplot(popunits_xy) +
  geom_sf(aes(fill = STATUS), color = "white", size = 0.1) +
  labs(title = "Conservation Status of Grizzly Bear Population Units in BC") +
  scale_fill_viridis(discrete = T, alpha = 0.8, direction = -1) +
  theme_minimal() +
  geom_text_repel(aes(label = POPULATION_NAME, x = lng, y = lat),
                  size = 2, force =  0.5) # Needs some tweaking - some labels off polygons
staticmap # plot map

# Plot basic POPULATION estimate per management unit
popplot <- ggplot(by_gbpu) +
  geom_col(aes(x = reorder(POPULATION_NAME, -Estimate), y = Estimate)) +
  theme_soe() +
  scale_y_continuous("Population Estimate") +
  scale_x_discrete("Population Unit") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + # rotate labels
  ggtitle("Grizzly Bear Population Estimate per Unit") +
  theme(plot.title = element_text(hjust = 0.5))
popplot # Display plot

# Plot basic DENSITY estimate per management unit
densplot <- ggplot(by_gbpu) +
  geom_col(aes(x = reorder(POPULATION_NAME, -Density), y = Density)) +
  theme_soe() +
  scale_y_continuous("Population Density Estimate") +
  scale_x_discrete("Population Unit") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + # rotate labels
  ggtitle("Grizzly Bear Population Density Estimate per Unit") +
  theme(plot.title = element_text(hjust = 0.5))
densplot # Display plot

# Build  static grizzly  density choropleth
grizzlydensmap <- ggplot(popunits_xy) +
  geom_sf(aes(fill = Density)) +
  labs(title = "Grizzly Bear Population Density in British Columbia") +
  theme_minimal() + theme(plot.title = element_text(hjust = 0.5)) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .5) +
  geom_text_repel(aes(label = POPULATION_NAME, x = lng, y = lat),
                  size = 2, force =  0.5)
  #geom_text(aes(label = POPULATION_NAME, x = lng, y = lat),
            #position = position_dodge(width = 0.8), size = 3) # Needs some tweaking - some labels off polygons
grizzlydensmap # plot map

# Get stamen map
# map <- get_map(bbox = c(left = 275942.4, bottom = 367537.4, right = 1867409.2,
#                              top = 1735251.6 ), maptype = "terrain-background", zoom = 1)

# Build static grizzly population choropleth
grizzlypopmap <- ggplot(popunits_xy) +
  geom_sf(aes(fill = Estimate)) +
  labs(title = "Grizzly Bear Population Estimates for British Columbia") +
  theme_minimal() + theme(plot.title = element_text(hjust = 0.5)) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .5) +
  geom_text_repel(aes(label = POPULATION_NAME, x = lng, y = lat),
                  size = 2, force =  0.5)
grizzlypopmap # plot map

## --
## MORTALITY DATA
## --

# Create colour palette for all the plots
chartFill <- brewer.pal(7, "Set2")
names(chartFill) <- levels(mort_gbpu$KILL_CODE)
plot.fillScale <- scale_fill_manual(values=chartFill)

# Summarise # of bears killed per kill type + management unit
mort_gbpu <- bearmort %>%
  group_by(GBPU_NAME, KILL_CODE, HUNT_YEAR) %>%
  summarise(COUNT = n())
glimpse(mort_gbpu)

# Plot for basic POPULATION estimate per management unit
mortplot <- ggplot(mort_gbpu, aes(x = HUNT_YEAR, y = COUNT,
                            group = KILL_CODE, fill = KILL_CODE)) +
  geom_bar(stat = "identity") + # Add bar for each year w/ fill = kill type
  theme_soe() +
  scale_fill_brewer(type = "seq", palette = "Set2") +
  scale_x_continuous(breaks=seq(1970, 2017, by = 5)) +
  labs(title = "Grizzly Bear Mortality for the Province of BC, 1976-2017", x = "Year",
       y = "Number of Grizzly Bears Killed", fill = "Mortality Type") +
  theme(plot.title = element_text(hjust = 0.5))
mortplot


