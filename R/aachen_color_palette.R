#' Creates a plot showing all avaiable colors of the RWTH palette
#' @export
#' @examples display_rwth_colors()
#' @import dplyr
#' @import tibble
#' @import ggplot2
#' @import stringr
display_aachen_colors = function() {
  aachen_colors_df %>%
    mutate(color = str_to_title(color)) %>%
    mutate(color = factor(color, unique(color)),
           intensity = factor(intensity, unique(intensity)),
           query = factor(query, query)) %>%
    ggplot(aes(x=color, y=intensity, color=query)) +
    geom_point(size=9) +
    scale_color_manual(values = aachen_colors_df$hex) +
    theme_minimal() +
    theme(legend.position = "none",
          axis.text = element_text(size=12),
          title = element_text(size=14)) +
    coord_flip() +
    labs(x = "", y="Intensity [%]") +
    ggtitle("Aachen color palette")
}

#' Queries colors from RWTH color palette
#'
#' @param colors Query of colors (see @display_aachen_colors() ) for querie names
#'
#' @return HEX code of queried colors
#' @export
#'
#' @examples aachen_color("maygreen")
#' @examples aachen_color(c("blue", "blue75", "blue50", "blue25", "blue10))
aachen_color = function(colors) {
  if (!all(colors %in% aachen_colors_df$query)) {
    wrong_queries = tibble(query = colors) %>%
      anti_join(aachen_colors_df, by="query") %>%
      pull(query)
    warning(paste("The following queries are not available:",
                  paste(wrong_queries, collapse = ", ")))
  }
  tibble(query = colors) %>%
    inner_join(aachen_colors_df, by="query") %>%
    pull(hex)
}
