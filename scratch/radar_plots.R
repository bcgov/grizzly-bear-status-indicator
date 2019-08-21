library(tidyverse)

test <- threat_calc %>%
  filter(gbpu_name %in% c("North Cascades", "Central Monashee", "Bulkley-Lakes", "Knight-Bute", "Cassiar")) %>%
  mutate(trend_adj = trend * -1) %>%
  select(gbpu_name, calcsrank, trend_adj, popiso_rank_adj, threat_rank_adj) %>%
  gather("metric", "score", -gbpu_name, -calcsrank, trend_adj, popiso_rank_adj, threat_rank_adj) %>%
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

(
  p <- ggplot(test, aes(x = metric, y = score)) +
    facet_wrap(~ gbpu_name) +
    geom_polygon(aes(group = NA, fill = as.numeric(str_extract(calcsrank, "\\d")),
                     colour = as.numeric(str_extract(calcsrank, "\\d"))),
                 alpha = 0.6, size = 2) +
    geom_errorbar(aes(x = metric, ymin = 0, ymax = max_val),
                  width = 0.1, colour = "grey40") +
    scale_colour_viridis_c(direction = -1, guide = "none") +
    scale_fill_viridis_c(direction = -1, guide = "none") +
    # scale_y_continuous(expand = expand_scale(mult = 0, add = 0)) +
    geom_text(aes(x = metric, y = label_pos, label = label),
              colour = "grey40") +
    geom_text(aes(label = calcsrank, colour = as.numeric(str_extract(calcsrank, "\\d"))),
              x = 0.5, y = 2, size = 4) +
    geom_text(aes(label = gbpu_name),
              x = 0.5, y = 4.5, size = 5, colour = "grey40") +
    coord_radar(clip = "off") +
    theme_void() +
    theme(plot.margin = unit(c(0,0,0,0), "lines"), strip.text = element_blank())
)

ggsave("radar_example.png")

