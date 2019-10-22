rwth_colors_df = read_csv("data-raw/rwth_colors.csv") %>%
  mutate(query = case_when(intensity == 100 ~ color,
                           intensity != 100 ~ paste0(color, intensity)))

devtools::use_data(rwth_colors_df, internal = T, overwrite = T)

# create figure for README
palette = display_rwth_colors()
ggsave("man/figures/rwth_color_palette.png", palette, width = 4, height=6)
