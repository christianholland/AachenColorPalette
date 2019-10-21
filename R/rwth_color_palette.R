#' Creates a plot showing all avaiable colors of the RWTH palette
#' @export
#' @examples display_rwth_colors()
#' @import dplyr
#' @import tibble
#' @import ggplot2
#' @import stringr
display_rwth_colors = function() {
  rwth_colors_df %>%
    mutate(color = str_to_title(color)) %>%
    mutate(color = factor(color, unique(color)),
           intensity = factor(intensity, unique(intensity)),
           query = factor(query, query)) %>%
    ggplot(aes(x=color, y=intensity, color=query)) +
    geom_point(size=8) +
    scale_color_manual(values = rwth_colors_df$hex) +
    theme_minimal() +
    theme(legend.position = "none") +
    coord_flip() +
    labs(x = "", y="Intensity [%]") +
    ggtitle("RWTH color palette")
}

#' Queries colors from RWTH color palette
#'
#' @param colors Query of colors (see @display_rwth_colors() ) for querie names
#'
#' @return HEX code of queried colors
#' @export
#'
#' @examples rwth_color("maygreen")
#' @examples rwth_color(c("blue", "blue75", "blue50", "blue25", "blue10))
rwth_color = function(colors) {
  if (!all(colors %in% rwth_colors_df$query)) {
    wrong_queries = tibble(query = colors) %>%
      anti_join(rwth_colors_df, by="query") %>%
      pull(query)
    warning(paste("The following queries are not available:",
                  paste(wrong_queries, collapse = ", ")))
  }
  tibble(query = colors) %>%
    inner_join(rwth_colors_df, by="query") %>%
    pull(hex)
}
