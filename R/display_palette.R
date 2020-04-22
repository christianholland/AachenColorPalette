#' Creates a plot showing all avaiable colors of the Aachen palette
#' @export
#'
#' @import ggplot2
#' @import stringr
#' @examples display_aachen_colors()
display_aachen_colors = function() {
  aachen_colors_df %>%
    dplyr::mutate(color = stringr::str_to_title(.data$color)) %>%
    dplyr::mutate(color = factor(.data$color, unique(.data$color)),
                  intensity = factor(.data$intensity, unique(.data$intensity)),
                  query = factor(.data$query, .data$query)) %>%
    ggplot2::ggplot(ggplot2::aes(x=.data$color, y=.data$intensity,
                                 color=.data$query)) +
    ggplot2::geom_point(size=9) +
    ggplot2::scale_color_manual(values = aachen_colors_df$hex) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "none",
                   axis.text = ggplot2::element_text(size=12),
                   title = ggplot2::element_text(size=14)) +
    ggplot2::coord_flip() +
    ggplot2::labs(x = "", y="Intensity [%]") +
    ggplot2::ggtitle("Aachen color palette")
}
