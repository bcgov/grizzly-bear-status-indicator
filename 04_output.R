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
results <- "C:/dev/plot-results"

# List of plots
plots <- list()

# Create plot function
Mortality <- function(mort_gbpu) {

  # Create list of GBPU
  gbpu_list <- unique(mort_gbpu$GBPU_NAME)

  # Create ggplot graph loop
  for (i in seq_along(gbpu_list)) {

    # Create plot for each GBPU
    plot <-
      ggplot(subset(mort_gbpu, mort_gbpu$GBPU_NAME == gbpu_list[i]),
                    aes(x = HUNT_YEAR, y = COUNT,
                        fill = KILL_CODE)) +
               geom_bar(stat = "identity") + # Add bar for each year w/ fill = kill type
               theme_soe() +
               scale_fill_brewer(7, palette = "Set2") +
               scale_x_continuous(breaks=seq(1970, 2017, by = 5)) +
               labs(x = "Year", y = "Number of Grizzly Bears Killed",
                    fill = "Mortality Type") +
               ggtitle(paste("Mortality History for the '"
                             ,gbpu_list[i]
                             , "' Population Unit"
                             , ", 1976-2017"
                             ,sep = ""))

    # Print plots
    print(plot)

  }
}

# Run graphing function
Mortality(mort_gbpu)
