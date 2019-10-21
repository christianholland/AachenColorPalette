rwth_colors_df = read_csv("data-raw/rwth_colors.csv") %>%
  mutate(query = case_when(intensity == 100 ~ color,
                           intensity != 100 ~ paste0(color, intensity)))

devtools::use_data(rwth_colors_df, internal = T, overwrite = T)
