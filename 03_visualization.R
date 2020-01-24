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
library(dplyr)

if (!exists("grizzdata_full")) load("data/grizzdata_full.rds")
if (!exists("grizz_morts")) load("data/grizz_morts.rds")

if (!exists("dataviz/leaflet/concern_plots/"))
dir.create("dataviz/leaflet/concern_plots/", showWarnings = FALSE)
dir.create("dataviz/leaflet/threat_plots/", showWarnings = FALSE)

# Create list of GBPU
gbpu_list <- unique(grizzdata_full$gbpu_name)

# create the colour pallet for all figures
palv <- c("Negligible" = "#440154FF", "Low" = "#3B528BFF" ,
          "Medium" = "#21908CFF", "High" = "#5DC863FF" ,
          "Very High" = "#FDE725FF", "NA" = "#808080")

mrank_palette <- c(
  "M1" = "#FDE725FF" ,
  "M2" = "#5DC863FF",
  "M3" = "#21908CFF",
  "M4" = "#3B528BFF" ,
  "M5" = "#440154FF",
  "NA" = "#808080"
)



## Create Conservation Concern Popup Plots ---------------------------------

grizz.df <- as.data.frame(grizzdata_full)

cc_data <- grizz.df %>%
  mutate(trend_adj = as.numeric(trend) * -1) %>%
  select(gbpu_name, calcsrank, trend_adj, popiso_rank_adj, threat_rank_adj, con_stats) %>%
  gather("metric", "score", -gbpu_name, -calcsrank, -con_stats, trend_adj, popiso_rank_adj, threat_rank_adj) %>%
  mutate(max_val = case_when(metric == "trend_adj" ~ 1, metric == "popiso_rank_adj" ~ 4, metric == "threat_rank_adj" ~ 2),
         label = case_when(metric == "trend_adj" ~ "Trend", metric == "popiso_rank_adj" ~ "Population/\nIsolation", metric == "threat_rank_adj" ~ "Threat"),
         label_pos= case_when(metric == "trend_adj" ~ 2.2, metric == "popiso_rank_adj" ~ 5.5, metric == "threat_rank_adj" ~ 2.8)
  )

coord_radar <- function (theta = "x", start = 0, direction = 1, clip = "on") {
  theta <- match.arg(theta, c("x", "y"))
  r <- if (theta == "x") "y" else "x"
  ggproto("CordRadar", CoordPolar, theta = theta, r = r, start = start,
          direction = sign(direction),
          clip = clip,
          is_linear = function(coord) TRUE)
}


# Create radar plot list
radar_plot_list <- vector(length = length(gbpu_list), mode = "list")
names(radar_plot_list) <- gbpu_list


Radar_Plots <- function(data, name) {
  p <- ggplot(data, aes(x = metric, y = score)) +
    geom_polygon(aes(group = NA,
                     fill = calcsrank,
                     colour = calcsrank),
                 alpha = 0.7, size = 4) +
    geom_errorbar(aes(x = metric, ymin = 0, ymax = max_val),
                  width = 0.1, colour = "grey40", size = 1.5) +
    scale_colour_manual(guide = "none",
                           values = mrank_palette ) +
    scale_fill_manual(guide = "none",
                         values = mrank_palette ) +
    geom_text(aes(x = metric, y = label_pos, label = label),
              colour = "grey40", size = 6) +
    # geom_text(aes(label = calcsrank), colour = "grey40",
    #          x = 0.5, y = 2, size = 12) +
    coord_radar(clip = "off") +
    theme_void() +
    theme(strip.text = element_blank(),
          plot.margin = unit(c(-4, -6, -6, -13), "cm"))
 p

}

# Create ggplot graph loop
 plots <- for (n in gbpu_list) {
   print(n)
   data <- filter(cc_data, gbpu_name == n)
   if(length(data$gbpu_name) == 0) {
     p = NA
   } else {
   p <- Radar_Plots(data, n)
   ggsave(p, file = paste0("dataviz/leaflet/concern_plots/", n, ".svg"),
          width = unit(6, "in"), height = unit(5, "in"))

 }
   radar_plot_list[[n]] <- p

 }


# THREAT POPUP MAPPING ------------------------------------------------------

# Subplot 1: Overall plots

threat_calc <- threat_calc %>%
  select(gbpu_name, ends_with("calc")) %>%
  rename(
  "Residential" = residentialcalc,
  "Agriculture" = agriculturecalc,
  "Energy" = energycalc,
  "Transportation" = transportationcalc,
  "Biological Use" = biousecalc,
  "Human Intrusion" = humanintrusioncalc,
  "Climate Change" = climatechangecalc
)

total_threats <- gather(threat_calc, key = "threat", value = "ranking",
                        Residential, Agriculture, Energy, Transportation,
                        'Biological Use', 'Human Intrusion', 'Climate Change') %>%
  select(gbpu_name, threat, ranking)


total_threats$ranking <- factor(total_threats$ranking, ordered = TRUE,
                                levels = c("Negligible", "Low", "Medium", "High", "Very High"))

saveRDS(total_threats, file = "dataviz/leaflet/threat_plots/total_threats.rds")


# Create list for plots
threat_plot_list <- vector(length = length(gbpu_list), mode = "list")
names(threat_plot_list) <- gbpu_list

# Create plotting function
Threat_Plots <- function(data, name) {
  make_plot <- ggplot(data, aes(x = threat, y = ranking,
                                fill = ranking, alpha = 0.95)) +
    geom_bar(stat = "identity") + # Add bar for each threat variable
    scale_fill_manual(values = palv) +
    labs(x = "Threat", y = "Threat Ranking",
         fill = "Ranking") +
    ggtitle(name) +
    theme(legend.position = "none") +
    theme_soe() + theme(plot.title = element_text(hjust = 0.5), # Centre title
                       legend.position = "none",
                      plot.caption = element_text(hjust = 0)) +  # L-align caption
   scale_y_discrete(limits = c("Negligible", "Low", "Medium", "High"),
                    drop = FALSE, na.translate = FALSE)
  make_plot + coord_flip()

}

# Create ggplot graph loop
plots <- for (n in gbpu_list) {
  print(n)
  data <- filter(total_threats, gbpu_name == n)
  if(length(data$gbpu_name) == 0) {
    p = NA
  } else {
  p <- Threat_Plots(data, n)
  ggsave(p, file = paste0("dataviz/leaflet/threat_plots/", n, "_threat.svg"))
  }
  threat_plot_list[[n]] <- p
}



# other sub plots

subplot_cats <- c("residential",  "agriculture", "energy", "transport",
                  "biouse","humanintrusion","climatechange")

threat_sub <- threat_sub %>%
  filter(catergory %in% subplot_cats) %>%
  filter(threat_sub_name != "NA")


threat_sub_plot_list <- vector(length = length(gbpu_list), mode = "list")
names(threat_sub_plot_list) <- gbpu_list


# Create ggplot graph loop
plots <- for (n in gbpu_list) {
  print(n)

  threat_sub_data <-  filter(threat_sub, gbpu_name == n)

  if(length(threat_sub_data$gbpu_name) == 0) {
    p = NA
  } else {

    # loop through the catergories
    for (cat in subplot_cats) {

      cat_data <- filter(threat_sub_data, catergory == cat)
      print(cat)

      cat_plot <- ggplot(cat_data, aes(x = threat_sub_name, y = rank,
                                       fill = rank, alpha = 0.95)) +
        geom_bar(stat = "identity") + # Add bar for each threat variable
        scale_fill_manual(values = palv) +
        labs(x = "Sub threat", y = "Threat Ranking",
             fill = "Ranking") +
        ggtitle(paste0(n,": ", cat, " sub threats")) +
        theme(legend.position = "none") +
        theme_soe() + theme(plot.title = element_text(hjust = 0.5), # Centre title
                            legend.position = "none",
                            plot.caption = element_text(hjust = 0)) +  # L-align caption
        scale_y_discrete(limits = c("Negligible", "Low", "Medium"),
                         drop = FALSE, na.translate = FALSE)

      cat_plot <- cat_plot + coord_flip()

      ggsave(cat_plot, file = paste0("dataviz/leaflet/threat_plots/", n, "_",cat,".svg"))

    }
    threat_sub_plot_list[[n]] <- cat_plot
  }

}



# mortality popup plots ------------------------------------------------------

pal_mort <- c("Road Kill*" = "#77AADD",
              "Rail Kill*" = "#EE8866" ,
              "Pick Up (post-2004)*" = "#EEDD88",
              "Pick Up (pre-2004)*" = "#FFAABB" ,
              "Hunter Kill" = "#44BB99",
              "Illegal" = "#99DDFF",
              "Animal Control" = "#AAAA00" )

mort_sum <- grizz_morts %>%
  rename_all(tolower) %>%
  st_drop_geometry() %>%
  group_by(gbpu_name, hunt_year, kill_code) %>%
  summarise(count = n())

# Create list of GBPU
gbpu_list <- unique(grizzdata_full$gbpu_name)

# Create plotting function
mort_Plots <- function(mdata, name) {
  make_mplot <- ggplot(mdata, aes(y = count, x = hunt_year, fill = kill_code)) +
    geom_bar(stat = "identity") + # Add bar for each threat variable
    scale_fill_manual(values = pal_mort) +
    xlim(1976, 2017) +
    labs(x = "Year", y = "Number of Grizzlies killed") +
    ggtitle(paste0("Historic Grizzly Bear Mortality (1976 - 2017) for ", n ," GBPU")) +
    theme_soe() + theme(plot.title = element_text(hjust = 0.5), # Centre title
                        plot.caption = element_text(hjust = 0)) +  # L-align caption
    theme(legend.position = "top", legend.title = element_blank())

   make_mplot
}

# Create list for plots
mort_plot_list <- vector(length = length(gbpu_list), mode = "list")
names(mort_plot_list) <- gbpu_list

# Create ggplot graph loop
plots <- for (n in gbpu_list) {
  print(n)
  mdata <- mort_sum %>% filter(gbpu_name == n)
  if(length(mdata$gbpu_name) == 0) {
    p = NA
  } else {
    p <- mort_Plots(mdata, name)
    ggsave(p, file = paste0("dataviz/leaflet/threat_plots/", n, "_mort.svg"))
  }
  mort_plot_list[[n]] <- p
}
