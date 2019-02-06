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

##*******************
## OPTION 1: FOR LOOP
##*******************
# Create list of grizzly  population unit names
gbpu_names <- unique(mort_summary$gbpu_name)

# Make list of grizzly plots
grizz_plotlist <- vector("list", length(gbpu_names))
names(grizz_plotlist) <- gbpu_names # Assign names to vector
glimpse(grizz_plotlist)

# Create plot function
Mortality <- function(mort_summary) {

  # Create list of GBPU
  gbpu_list <- unique(mort_summary$gbpu_name)

  # Create ggplot graph loop
  for (i in seq_along(gbpu_list)) {

    # Create plot for each GBPU
    mortality_plot <-
      ggplot(subset(mort_summary, mort_summary$gbpu_name == gbpu_list[i]),
                    aes(x = hunt_year, y = count,
                        fill = kill_code)) +
               geom_bar(stat = "identity") + # Add bar for each year w/ fill = kill type
               scale_fill_brewer("Mortality Type", palette = "Set2") +
               scale_x_continuous(breaks=seq(1970, 2017, by = 5)) +
               labs(x = "Year", y = "Number of Grizzly Bears Killed",
                    fill = "Mortality Type", caption = caption.text) + # Legend text
               ggtitle(paste("Mortality History for the '"
                             ,gbpu_list[i]
                             , "' Population Unit"
                             , ", 1976-2017"
                             ,sep = "")) +
      theme_bw() + theme(plot.title = element_text(hjust = 0.5), # Centre main title
                         legend.position = "bottom",
                         plot.caption = element_text(hjust = 0)) # Left-align caption

    list(barchart = mortality_plot)

    ggsave(mortality_plot, file = paste0("out/", gbpu_names[i], ".svg"))

    # Print plots
    print(mortality_plot)

  }
}

# Run graphing function
Mortality(mort_summary)

##******************************
## OPTION TWO: BARCHART FUNCTION
##******************************

# Create list of GBPU
gbpu_list <- unique(mort_gbpu$gbpu_name)

# Barchart function
charts <- function() {
  ggplot(mort_gbpu, aes(x = hunt_year, y = count, fill = kill_code)) +
  geom_bar(stat = "identity") + # Add bar for each year w/ fill = kill type
  scale_fill_brewer("Mortality Type", palette = "Set2") +
  scale_x_continuous(breaks=seq(1970, 2017, by = 5)) +
  labs(x = "Year", y = "Number of Grizzly Bears Killed",
       fill = "Mortality Type", caption = caption.text) + # Legend text
  ggtitle(paste("Mortality History for the ' "
                , "' Population Unit"
                , ", 1976-2017"
                ,sep = "")) +
  theme_bw() + theme(plot.title = element_text(hjust = 0.5), # Centre main title
                     legend.position = "bottom",
                     plot.caption = element_text(hjust = 0)) # Left-align caption
}

# Loop through list
plot_list <- imap(gbpu_list, ~ {
  print(.y)
  mortbarcharts <- charts
  # Save in list
  list(barchart = mortbarcharts)
})

# Folder to put plot results
saveRDS(plot_list, file = "/dev/plotlist.rds")

# Save svgs
