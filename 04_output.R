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

# Folder to put plot results
results <- "/dev/plot-results"

# List of plots
plotlist <- list()

# Create plot function
Mortality <- function(mort_gbpu) {

  # Create list of GBPU
  gbpu_list <- unique(mort_gbpu$gbpu_name)

  # Create ggplot graph loop
  for (i in seq_along(gbpu_list)) {

    # Create plot for each GBPU
    plot <-
      ggplot(subset(mort_gbpu, mort_gbpu$gbpu_name == gbpu_list[i]),
                    aes(x = hunt_year, y = count,
                        fill = kill_code)) +
               geom_bar(stat = "identity") + # Add bar for each year w/ fill = kill type
               scale_fill_brewer("Mortality Type", palette = "Set2") +
               scale_x_continuous(breaks=seq(1970, 2017, by = 5)) +
               labs(x = "Year", y = "Number of Grizzly Bears Killed",
                    fill = "Mortality Type") + # Legend text
               ggtitle(paste("Mortality History for the '"
                             ,gbpu_list[i]
                             , "' Population Unit"
                             , ", 1976-2017"
                             ,sep = "")) +
      theme_bw() + theme(plot.title = element_text(hjust = 0.5), # Centre main title
                         legend.position = "bottom")

    plotlist <- c(plotlist, list(plot))

    # Print plots
    print(plot)

    # Save
    #ggsave(plot, file = paste(results,
     #                         'grizzly_graphs/',
      #                        gbpu_list[i]), plot = image, width = 10, height = 8)

  }
}

# Run graphing function
Mortality(mort_gbpu)
