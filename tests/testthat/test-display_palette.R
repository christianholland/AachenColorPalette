library(AachenColorPalette)

context("display-palette")

test_that("plot of color palette", {
  p = display_aachen_colors()
  vdiffr::expect_doppelganger("aachen-color-palette", p)
})
