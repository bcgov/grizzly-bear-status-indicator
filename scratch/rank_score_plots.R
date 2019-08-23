library(tidyverse)
library(ggforce)
library(scales)
library(here)
library(sf)

#install.packages("ggparliament")
library(ggparliament)


## work in progress.....
#if (!exists("threat_sum_plot")) load(here("tmp", "plots.RData"))
grizzdata_full <- read_rds(here("data/grizzdata_full.rds"))
grizzdata_full <- st_transform(grizzdata_full, crs = 4326)

# Conservation Status Pop_up figures
Tab1_figs <- "out_tab1"

rank_data <- grizzdata_full %>%
  dplyr::select(gbpu_name, calcsrank, calc_rank_check, trend, popiso_rank_adj, threat_rank_adj) %>%
  mutate(Rank = calc_rank_check,Pop_iso = popiso_rank_adj,
         threat = threat_rank_adj) %>%
  select(gbpu_name, Rank, Pop_iso, trend, threat) %>%
  gather(catergory, "Score", 2:5) %>%
  mutate(Rscore = as.numeric(Score)*100)

  st_geometry(rank_data) <- NULL

#for(i in 1:length(unique(gbpu_name))) {
  rdata <- rank_data %>% filter(gbpu_name == "Rocky")
  rdata <- rdata %>%
    mutate(colour = c("grey","red","blue",'yellow'))

   ### Example 1:
  rdata <- parliament_data(election_data = rdata,
                              type = "semicircle",
                              parl_rows = 10,
                              party_seats = rdata$Rscore)

  rep <- ggplot(rdata, aes(x, y, colour = catergory)) +
    geom_parliament_seats(size = 5) +
    geom_parliament_bar(colour = colour, party = catergory) +
    theme_no_axes()
  rep

  ### Example 1:
  rdata$catergory <- factor(rdata$catergory)
  rdata$Share <- as.numeric(rdata$Score) / sum(as.numeric(rdata$Score))
  rdata$ymax <- cumsum(rdata$Share)
  rdata$ymin <- c(0, head(rdata$ymax, n= -1))

  rep2 = ggplot(rdata, aes(fill = catergory, ymax = ymax, ymin = ymin, xmax = 2, xmin = 1)) +
    geom_rect() +
    coord_polar(theta = "y",start=-pi/2) + xlim(c(0, 2)) + ylim(c(0,2)) +
    scale_color_manual(values = c("blue","grey", "red","yellow"), aesthetics = "fill") +
    theme_void() +
    #geom_text(aes(x = 2, y = 0, label = "M5")) +
    annotate(geom = "text", x = 2, y = 0, label = "M5", size = 4) +
    annotate(geom = "text", x = 2, y = 1, label = "M1", size = 4)
  rep2




# example 1
dummydata <- data.frame(gbpu = "Fake",
                        trend_cat = ">25%", trend_adj = 1,
                        popiso_cat = "EA", popiso_adj = 2,
                        threat_cat = "Medium", threat_adj = 1,
                        stringsAsFactors = FALSE) %>%
  mutate(calc_rank = pmax(5 - trend_adj - popiso_adj - threat_adj, 1),
         M_rank = paste0("M", calc_rank))

my_arrow <- arrow(type = "open", angle = 20, length = unit(0.5, "cm"))

ggplot(dummydata, aes(y = 1, x = calc_rank, fill = calc_rank)) +
  geom_col(width = 0.1)  +
  scale_fill_viridis_c(limits = c(0,5), direction = -1, guide = "none") +
  scale_x_continuous(limits = c(0,5),
                     expand = c(0,0),
                     labels = c("Extirpated", "M1 (High Concern)",
                                "M2", "M3", "M4", "M5 (Low Concern)")) +
  scale_y_continuous(expand = c(0,0.05)) +
  geom_segment(y = 0.25, yend = 0.25,
           aes(xend = 5 - trend_adj + 0.05,
           x = 5, size = 2, color = "red"),
           arrow = my_arrow, size = 2) +
  annotate("text", hjust = 0, y = 0.3, x = 4.5, label = "Trend: >25%") +
  geom_segment(y = 0.25, yend = 0.25,
           aes(xend = 5 - trend_adj - popiso_adj + 0.05,
           x = 5 - trend_adj),
           arrow = my_arrow, size = 2) +
  annotate("text", hjust = 0, y = 0.3, x = 3, label = "Population/Isolation: 'EA'") +
  geom_segment(y = 0.25, yend = 0.25,
           aes(xend = 5 - trend_adj - popiso_adj - threat_adj + 0.05,
           x = 5 - trend_adj - popiso_adj),
           arrow = my_arrow, size = 2) +
  #viridis::scale_colour_viridis(name = )
  annotate("text", hjust = 0, y = 0.3, x = 1.5, label = "Threat Score: Medium") +
  coord_flip() +
  theme_void() +
  theme(axis.text.y = element_text(),
        axis.line.y = element_line(),
        axis.ticks.y = element_line(),
        plot.margin = unit(c(rep(1,4)), "lines"))

roseplotdata <- dummydata %>%
  select(-ends_with("_cat"), -M_rank, -calc_rank) %>%
  gather(key = "variable", value = "value", -gbpu) %>%
  mutate(variable = case_when(
    variable == "popiso_adj" ~ "Popolation +\nIsolation",
    variable == "threat_adj" ~ "Threats",
    variable == "trend_adj" ~ "Trend"
  ))


ggplot(roseplotdata, aes(x = variable, y = value, fill = value)) +
  geom_hline(yintercept = 1:4, colour = "grey80") +
  geom_bar(stat = "identity", width = 0.9, colour = "grey30", size = 0.5) +
  scale_fill_viridis_c(guide = "none", limits = c(0,4)) +
  scale_y_continuous(limits = c(-0.7,4),
                     expand = expand_scale(mult = 0, add = 0)) +
  scale_x_discrete(expand = expand_scale(mult = 0, add = 0.5)) +
  coord_polar() +
  geom_text(aes(label = -value, y = pmax(value * 0.5, 0.5)), size = 6,
            colour = "white") +
  annotate("text", x = 1, y = -0.7, label = dummydata$M_rank, size = 6,
           colour = "grey20", fontface = "bold") +
  geom_hline(yintercept = 0, colour = "grey20") +
  theme_void() +
  theme(axis.text.x = element_text(size = 11, colour = "grey30",
                                   face = "bold")) +
  labs(title = "Impact of rank factors on final M-Rank")

