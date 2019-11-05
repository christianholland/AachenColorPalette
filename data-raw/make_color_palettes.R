aachen_colors_df = read.csv("data-raw/aachen_colors.csv",
                            stringsAsFactors = F, check.names = F) %>%
  mutate(query = case_when(intensity == 100 ~ color,
                           intensity != 100 ~ paste0(color, intensity)))

use_data(aachen_colors_df, internal = T, overwrite = T)

# create figure for README
palette = display_aachen_colors()
ggsave("man/figures/aachen_color_palette.png", palette, width = 4, height=6)
