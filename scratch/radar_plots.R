library(tidyverse)

test <- threat_calc %>%
  # filter(gbpu_name == "Garibaldi-Pitt") %>%
  mutate(trend_adj = trend * -1) %>%
  select(gbpu_name, calcsrank, trend_adj, popiso_rank_adj, threat_rank_adj) %>%
  gather("metric", "score", -gbpu_name, -calcsrank, trend_adj, popiso_rank_adj, threat_rank_adj) %>%
  mutate(max_val = case_when(metric == "trend_adj" ~ 1, metric == "popiso_rank_adj" ~ 4, metric == "threat_rank_adj" ~ 2),
         label = case_when(metric == "trend_adj" ~ "Trend", metric == "popiso_rank_adj" ~ "Population/\nIslotion", metric == "threat_rank_adj" ~ "Threat")
         )

coord_radar <- function (theta = "x", start = 0, direction = 1) {
  theta <- match.arg(theta, c("x", "y"))
  r <- if (theta == "x") "y" else "x"
  ggproto("CordRadar", CoordPolar, theta = theta, r = r, start = start,
          direction = sign(direction),
          is_linear = function(coord) TRUE)
}

(
  p <- ggplot(test, aes(x = metric, y = score)) +
    facet_wrap(~ gbpu_name) +
    geom_errorbar(aes(x = metric, ymin = 0, ymax = max_val), width = 0.1) +
    geom_path(aes(group = NA, colour = as.numeric(str_extract(calcsrank, "\\d")))) +
    geom_polygon(aes(group = NA, fill = as.numeric(str_extract(calcsrank, "\\d")))) +
    scale_colour_viridis_c(direction = -1, guide = "none") +
    scale_fill_viridis_c(direction = -1, guide = "none") +
    scale_y_continuous(limits = c(-0,5),
                       expand = expand_scale(mult = 0, add = 0)) +
    geom_text(aes(x = metric, y = max_val + 1, label = label)) +
    coord_radar() +
    theme_void()
)

