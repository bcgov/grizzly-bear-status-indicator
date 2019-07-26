library(tidyverse)

dummydata <- data.frame(gbpu = "Fake",
                        trend_cat = ">25%", trend_adj = 1,
                        popiso_cat = "EA", popiso_adj = 2,
                        threat_cat = "Medium", threat_adj = 1,
                        stringsAsFactors = FALSE) %>%
  mutate(calc_rank = pmax(5 - trend_adj - popiso_adj - threat_adj, 1),
         M_rank = paste0("M", calc_rank))

ggplot(mapping = aes(y = seq(from = 0, to = 1, length.out = 5),
                     x = dummydata$calc_rank, fill = dummydata$calc_rank)) +
  geom_col(width = 0.1)  +
  scale_fill_viridis_c(limits = c(0,5), direction = -1, guide = "none") +
  scale_x_continuous(limits = c(0,5),
                     labels = c("Extirpated", "M1 (High Concern)",
                                "M2", "M3", "M4", "M5 (Low Concern)")) +
  scale_y_continuous(limits = c(0,1), expand = c(0,0)) +
  annotate("segment", y = 0.25, yend = 0.25,
           xend = 5 - dummydata$trend_adj,
           x = 5,
           arrow = arrow()) +
  annotate("text", hjust = 0, y = 0.3, x = 4.5, label = "Trend: >25%") +
  annotate("segment", y = 0.25, yend = 0.25,
           xend = 5 - dummydata$trend_adj - dummydata$popiso_adj,
           x = 5 - dummydata$trend_adj,
           arrow = arrow()) +
  annotate("text", hjust = 0, y = 0.3, x = 3, label = "Population/Isoaltion: 'EA'") +
  annotate("segment", y = 0.25, yend = 0.25,
           xend = 5 - dummydata$trend_adj - dummydata$popiso_adj - dummydata$threat_adj,
           x = 5 - dummydata$trend_adj - dummydata$popiso_adj,
           arrow = arrow()) +
  annotate("text", hjust = 0, y = 0.3, x = 1.5, label = "Threat Score: Medium") +
  coord_flip() +
  theme_void() +
  theme(axis.text.y = element_text(),
        axis.line.y = element_line())

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

