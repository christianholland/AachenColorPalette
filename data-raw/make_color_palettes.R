aachen_colors_df = read.csv("data-raw/aachen_colors.csv",
                            stringsAsFactors = F, check.names = F) %>%
  mutate(query = case_when(intensity == 100 ~ color,
                           intensity != 100 ~ paste0(color, intensity)))

use_data(aachen_colors_df, internal = T, overwrite = T)

# create figure for README
palette = display_aachen_colors()
ggsave("man/figures/aachen_color_palette.png", palette, width = 4, height=6)

p = ggplot(mtcars, aes(x = wt, y = mpg, color=factor(cyl))) +
  geom_point() +
  scale_color_manual(values = aachen_color(c("bordeaux", "green", "turquoise")))

ggsave("man/figures/example_plot.png", p, width = 5, height=5)
