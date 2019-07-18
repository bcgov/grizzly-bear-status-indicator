## ----------------------------------------------------------------------------

gbpu_list <- unique(threats$gbpu_name)

gbpu_table <- function(data) {
  st_geometry(data) = NULL
  gather(data, key = Threat, value = Rank)
}

table_list <- map(gbpu_list, ~ {
  data = filter(threats, gbpu_name == .x)
  gbpu_table(data)
})

names(table_list) <- gbpu_list

# plot_list <- plot_list[names(table_list)]

plot_list_df <- tibble(
  popup_row1 = table_list
  # popup_row2 = plot_list
)

full_popup <- popup_combine_rows(plot_list_df)
saveRDS(full_popup, file = "out/full_popup.rds")
saveRDS(grizzdata_full, "data/grizzdata_full.rds")

