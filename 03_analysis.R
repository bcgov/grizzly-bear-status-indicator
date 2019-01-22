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

# Build basic static map for grizzly popunits/status
staticmap <- ggplot(popunits_simple) +
  geom_sf(aes(fill = STATUS)) +
  scale_fill_viridis(discrete = T, option = "magma") +
  theme_bw() +
  ggtitle("Conservation Status of Grizzly Bear Population Units in BC")
#  geom_sf_label(aes(label = GRIZZLY_BEAR_POP_UNIT_ID))
staticmap # plot map

# Summarise total pop estimate per management unit
by_gbpu <- bears %>%
  group_by(GBPU) %>%
  summarise(Estimate = sum(Estimate), Density = sum(Density)) %>% # Does this make sense to sum up density?
  arrange(desc(Estimate), GBPU)
glimpse(by_gbpu)

# Plot for basic POPULATION estimate per management unit
popplot <- ggplot(by_gbpu) +
  geom_col(aes(x = reorder(GBPU, -Estimate), y = Estimate)) +
  theme_soe() +
  scale_y_continuous("Population Estimate") +
  scale_x_discrete("Population Unit") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + # rotate labels
  ggtitle("Grizzly Bear Population Estimate per Unit") +
  theme(plot.title = element_text(hjust = 0.5))
popplot # Display plot

# Plot for basic DENSITY estimate per management unit
densplot <- ggplot(by_gbpu) +
  geom_col(aes(x = reorder(GBPU, -Density), y = Density)) +
  theme_soe() +
  scale_y_continuous("Population Density Estimate") +
  scale_x_discrete("Population Unit") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + # rotate labels
  ggtitle("Grizzly Bear Population Density Estimate per Unit") +
  theme(plot.title = element_text(hjust = 0.5))
densplot # Display plot

# Create bounding box
bc_bbox <- st_as_sfc(st_bbox(bc)) # convert to sfc
bc_bbox <- st_bbox(bc_bbox) # convert to bbox
bc_bbox

# Stamen map (terrain background)
#map <- get_stamenmap(bbox = c(left = 275942.4, bottom = 367537.4, right = 1867409.2,
#                              top = 1735251.6 ), maptype = "terrain-background", zoom = 1)

## --
## MORTALITY DATA
## --

# Create colour palette for all the plots
chartFill <- (palette = 'viridis')
names(chartFill) <- levels(mort_gbpu$KILL_CODE)
plot.fillScale <- scale_fill_manual(values=chartFill)

# Summarise # of bears killed per kill type + management unit
mort_gbpu <- bearmort %>%
  group_by(GBPU_NAME, KILL_CODE, HUNT_YEAR) %>%
  summarise(COUNT = n())
bab <- mort_gbpu %>% filter(GBPU_NAME == "Babine")
glimpse(mort_gbpu)

# Plot for basic POPULATION estimate per management unit
mortplot <- ggplot(bab, aes(x = HUNT_YEAR, y = COUNT,
                            group = KILL_CODE, fill = KILL_CODE)) +
  geom_bar(stat = "identity") + # Add bar for each year w/ fill = kill type
  theme_soe() +
  scale_fill_viridis(discrete = T, option = "plasma") +
  scale_x_continuous(breaks=seq(1970, 2017, by = 5)) +
  labs(title = "Grizzly Bear Mortality per Population Unit", x = "Year",
       y = "Number of Grizzly Bears Killed", fill = "Mortality Type") +
  theme(plot.title = element_text(hjust = 0.5))

mortplot
