##
## Threat Plot ##
##
require(tidyverse)

threat_calc <- read_xls(file.path(data_path, "Threat_Calc.xls")) %>%
  rename_all(tolower)

threat_calc <- threat_calc %>%
  select(gbpu_name, ends_with("calc"))

threat_calc <- threat_calc %>% rename(
  "Residential" = residentialcalc,
  "Agriculture" = agriculturecalc,
  "Energy" = energycalc,
  "Transportation" = transportationcalc,
  "Biouse" = biousecalc,
  "Human_Intrusion" = humanintrusioncalc,
  "Climate_Change" = climatechangecalc
)

total_threats <- gather(threat_calc, key = "threat", value = "ranking",
                      Residential, Agriculture, Energy, Transportation,
                      Biouse, Human_Intrusion, Climate_Change) %>%
  select(gbpu_name, threat, ranking)

total_threats$ranking <- factor(total_threats$ranking, ordered = TRUE,
                                      levels = c("Negligible", "Low", "Medium", "High", "Very High"))

# Create list of GBPU
gbpu_list <- unique(grizzdata_full$gbpu_name)

# Create list for plots
threat_plot_list <- vector(length = length(gbpu_list), mode = "list")
names(threat_plot_list) <- gbpu_list

# Create plotting function
Threat_Plots <- function(data, name) {
  # Create plot for a single GBPU
  make_plot <- ggplot(data, aes(x = threat, y = ranking,
                                     fill = ranking)) +
    geom_bar(stat = "identity") + # Add bar for each year w/ fill = kill type
    scale_fill_brewer("Threat Ranking", palette = "Set2") +
    #scale_x_continuous(breaks=seq(1970, 2017, by = 5)) +
    labs(x = "Threat", y = "Threat Ranking",
         fill = "Ranking") + # Legend text
    ggtitle(paste("Threat Ranking for the "
                  , name
                  , " Population Unit"
                  ,sep = "")) +
    theme_soe() + theme(plot.title = element_text(hjust = 0.5), # Centre title
                        legend.position = "bottom",
                        plot.caption = element_text(hjust = 0)) # L-align caption
  make_plot
}

# Create ggplot graph loop
plots <- for (n in gbpu_list) {
  print(n)
  data <- filter(total_threats, gbpu_name == n)
  # print(head(data))
  p <- Threat_Plots(data, n)
  threat_plot_list[[n]] <- p
  ggsave(p, file = paste0("out/", n, ".svg"))
}

# Check result
threat_plot_list[["Valhalla"]]

# Svg function
save_svg <- function(x, fname, ...) {
  svg_px(file = fname, ...)
  plot(x)
  dev.off()
}

# Save svgs to plot list
iwalk(threat_plot_list, ~ save_svg(.x, fname = paste0("out/", .y, ".svg"),
                            width = 600, height = 300))

# Save plots to file
saveRDS(threat_plot_list, file = "out/threat_plotlist.rds")

threat_popups <-  leafpop::popupGraph(threat_plot_list, type = "svg", width = 400,
                               height = 300)

saveRDS(threat_popups, "out/threat_popups.rds")

