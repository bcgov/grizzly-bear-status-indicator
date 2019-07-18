##
## Static threat mapping -------------------------------------------------------------
##
# Transportation:
transport_map <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = transportationcalc), color = "white", size = 0.1) +
  labs(title = "Transportation Threats to Grizzly Bear Populations in BC",
       col = "Threat Rank", fill = "Threat Class") +
  scale_fill_viridis(alpha = 0.6, discrete = T, option = "viridis",
                     direction = -1, na.value = "darkgrey") +
  theme_soe() + theme(plot.title = element_text(hjust = 0.5),
                      axis.title.x = element_blank(),
                      axis.title.y = element_blank(),
                      legend.background = element_rect(
                        fill = "lightgrey", size = 0.5,
                        linetype = "solid", colour = "darkgrey")) +
  geom_text(aes(label = grizzdata_full$gbpu_name, x = grizzdata_full$lng,
                y = grizzdata_full$lat), size = 2, check_overlap = T)
transport_map

# Energy map
energy_map <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = energycalc), color = "white", size = 0.1) +
  labs(title = "Energy Threats to Grizzly Bear Populations in BC",
       col = "Threat Rank", fill = "Threat Class") +
  scale_fill_viridis(alpha = 0.6, discrete = T, option = "viridis",
                     na.value = "darkgrey") +
  theme_soe() + theme(plot.title = element_text(hjust = 0.5),
                      axis.title.x = element_blank(),
                      axis.title.y = element_blank(),
                      legend.background = element_rect(
                        fill = "lightgrey", size = 0.5, linetype = "solid", colour = "darkgrey")) +
  geom_text(aes(label = grizzdata_full$gbpu_name, x = grizzdata_full$lng,
                y = grizzdata_full$lat), size = 2, check_overlap = T)
energy_map

# Human intrusion map
hi_map <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = humanintrusioncalc), color = "white", size = 0.1) +
  labs(title = "Human Intrusion Threats to Grizzly Bear Populations in BC",
       col = "Threat Rank", fill = "Threat Class") +
  scale_fill_viridis(alpha = 0.6, discrete = T, option = "viridis",
                     na.value = "darkgrey", direction = -1) +
  theme_soe() + theme(plot.title = element_text(hjust = 0.5),
                      axis.title.x = element_blank(),
                      axis.title.y = element_blank(),
                      legend.background = element_rect(
                        fill = "lightgrey", size = 0.5, linetype = "solid", colour = "darkgrey")) +
  geom_text(aes(label = grizzdata_full$gbpu_name, x = grizzdata_full$lng,
                y = grizzdata_full$lat), size = 2, check_overlap = T)
hi_map

#------------------------------------------------------------------------------

## POPULATION ESTIMATE PLOTTING ------------------------------------------------
# Plot basic POPULATION estimate per management unit
popplot <- ggplot(grizzdata_full) +
  geom_col(aes(x = reorder(gbpu_name, -adults), y = adults)) +
  theme_soe() +
  scale_y_continuous("Population Estimate") +
  scale_x_discrete("Population Unit") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + # rotate labels
  ggtitle("Grizzly Bear Population Estimate per Unit") +
  theme(plot.title = element_text(hjust = 0.5))
popplot # Display plot

# Build static grizzly population choropleth
grizzlypopmap <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = adults)) +
  labs(title = "Grizzly Bear Population Estimates for British Columbia",
       fill = "Population Estimate") +
  theme_minimal() + theme(plot.title = element_text(hjust = 0.5),
                          axis.title.x = element_blank(),
                          axis.title.y = element_blank()) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .5, na.value = "darkgrey") +
  geom_text(aes(label = grizzdata_full$gbpu_name, x = grizzdata_full$lng,
                y = grizzdata_full$lat), size = 2, check_overlap = F)
grizzlypopmap # plot map

## POPULATION DENSITY MAPPING: May not be needed for updated version ----------
# Build  static grizzly density choropleth
grizzlydensmap <- ggplot(grizzdata_full) +
  geom_sf(aes(fill = as.numeric(pop_density))) +
  labs(title = "Grizzly Bear Population Density in British Columbia",
       fill = "Population Density") + # Legend title
  theme_minimal() + theme(plot.title = element_text(hjust = 0.5), # Center main title
                          axis.title.x = element_blank(), # Remove xy labels
                          axis.title.y = element_blank()) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .5) + # Set colour (viridis)
  geom_text_repel(aes(label = gbpu_name, x = lng, y = lat),
                  size = 2, force =  0.5) # Offset labels
#geom_text(aes(label = gbpu_name, x = lng, y = lat),
#position = position_dodge(width = 0.8), size = 3) # Needs some tweaking - some labels off polygons
grizzlydensmap # plot map

# Plot basic density estimate per management unit
densplot <- ggplot(by_gbpu) +
  geom_col(aes(x = reorder(gbpu_name, -pop_density), y = pop_density)) +
  theme_soe() +
  scale_y_continuous("Population Density Estimate") +
  scale_x_discrete("Population Unit") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + # rotate labels
  ggtitle("Grizzly Bear Population Density Estimate per Unit") +
  theme(plot.title = element_text(hjust = 0.5))
densplot # Display plot
