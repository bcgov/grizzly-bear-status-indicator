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

# Create colour palette for future mapping (not currently used)
# pal <- c("Extirpated" = "firebrick2", "Threatened" = "yellow1", "Viable" = "forestgreen")

# Build basic static map for grizzly popunits/status
staticmap <- ggplot(popunits_xy) +
  geom_sf(aes(fill = status), color = "white", size = 0.1) +
  labs(title = "Conservation Status of Grizzly Bear Population Units in BC") +
  scale_fill_viridis(discrete = T, alpha = 0.8, direction = -1) +
  theme_minimal() +
  geom_text_repel(aes(label = population_name, x = lng, y = lat),
                  size = 2, force =  0.5) # Needs some tweaking - some labels off polygons
staticmap # plot map

# Plot basic POPULATION estimate per management unit
popplot <- ggplot(by_gbpu) +
  geom_col(aes(x = reorder(population_name, -pop_estimate), y = pop_estimate)) +
  theme_soe() +
  scale_y_continuous("Population Estimate") +
  scale_x_discrete("Population Unit") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + # rotate labels
  ggtitle("Grizzly Bear Population Estimate per Unit") +
  theme(plot.title = element_text(hjust = 0.5))
popplot # Display plot

# Plot basic DENSITY estimate per management unit
densplot <- ggplot(by_gbpu) +
  geom_col(aes(x = reorder(population_name, -pop_density), y = pop_density)) +
  theme_soe() +
  scale_y_continuous("Population Density Estimate") +
  scale_x_discrete("Population Unit") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + # rotate labels
  ggtitle("Grizzly Bear Population Density Estimate per Unit") +
  theme(plot.title = element_text(hjust = 0.5))
densplot # Display plot

# Build  static grizzly  density choropleth
grizzlydensmap <- ggplot(popunits_xy) +
  geom_sf(aes(fill = pop_density)) +
  labs(title = "Grizzly Bear Population Density in British Columbia",
       fill = "Population Density") + # Legend title
  theme_minimal() + theme(plot.title = element_text(hjust = 0.5), # Center main title
                          axis.title.x = element_blank(), # Remove xy labels
                          axis.title.y = element_blank()) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .5) + # Set colour (viridis)
  geom_text_repel(aes(label = population_name, x = lng, y = lat),
                  size = 2, force =  0.5) # Offset labels
  #geom_text(aes(label = POPULATION_NAME, x = lng, y = lat),
            #position = position_dodge(width = 0.8), size = 3) # Needs some tweaking - some labels off polygons
grizzlydensmap # plot map

vicmap <- ggmap(get_stamenmap(location = c(-123.534,48.397,-123.191,48.537), zoom = 10,
                        maptype = "toner-lite"))
plot(vicmap)

# Get stamen map
require(ggmap)
stamenbc <- get_stamenmap(location = c(-139.746094,48.107431,-119.707031,60.152442),
                          zoom = 1, maptype = "watercolor")
plot(stamenbc)

# Build static grizzly population choropleth
grizzlypopmap <- ggplot(popunits_xy) +
  geom_sf(aes(fill = pop_estimate)) +
  labs(title = "Grizzly Bear Population Estimates for British Columbia",
       fill = "Population Estimate") +
  theme_minimal() + theme(plot.title = element_text(hjust = 0.5),
                          axis.title.x = element_blank(),
                          axis.title.y = element_blank()) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .5) +
  geom_text_repel(aes(label = population_name, x = lng, y = lat),
                  size = 2, force =  0.5)
grizzlypopmap # plot map

## --
## MORTALITY DATA
## --

# Summarise # of bears killed per kill type + management unit
mort_gbpu <- bearmort %>%
  group_by(gbpu_name, kill_code, hunt_year) %>%
  summarise(count = n())
glimpse(mort_gbpu)

# Create colour palette for all the plots
chartFill <- brewer.pal(7, "Dark2")
names(chartFill) <- levels(mort_gbpu$kill_code)
plot.fillScale <- scale_fill_manual(values=chartFill)

# Caption text
caption.text <- paste("*Note that prior to 2004, road and rail kills",
                      " were not distinguished and were documented with",
                      " 'Pick Ups'.\nA Limited Entry Hunt (LEH) was",
                      " instituted province-wide for grizzly bears in",
                      " 1996.\nThere was a province-wide moratorium on",
                      " hunting grizzly bears in the spring of 2001."
                      , sep="")

# Plot for basic POPULATION estimate per management unit
mortplot <- ggplot(mort_gbpu, aes(x = hunt_year, y = count,
                            group = kill_code, fill = kill_code)) +
  geom_bar(stat = "identity") + # Add bar for each year w/ fill = kill type
  theme_bw() +
  scale_fill_brewer(type = "qual", palette = "Set2") +
  scale_x_continuous(breaks=seq(1970, 2017, by = 5)) +
  labs(title = "Grizzly Bear Mortality for the Province of British Columbia, 1976-2017",
       caption = caption.text,
       x = "Year", y = "Number of Grizzly Bears Killed", fill = "Mortality Type") +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "bottom",
        plot.caption = element_text(hjust = 0))
mortplot # Display figure

# Save figure
# ggsave(file = "mortplot1.svg", plot = mortplot, width = 10, height= 8)
