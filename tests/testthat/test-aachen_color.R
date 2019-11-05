library(AachenColorPalette)

test_that("aachen_color queries a single color", {
  expect_equal(aachen_color("blue"), "#00549F",
               aachen_color("green"), "#57AB27",
               aachen_color("magenta"), "#E30066")
})

test_that("aachen_color queries multiple colors", {
  expect_equal(aachen_color(c("blue", "blue75", "blue50", "blue25", "blue10")),
               c("#00549F", "#407FB7", "#8EBAE5", "#C7DDF2", "#E8F1FA"))
})

test_that("aachen_color queries not existing colors", {
  expect_warning(aachen_color("cyan"),
                 "The following queries are not available: cyan",
                 aachen_color(c("cyan", "cyan50")),
                 "The following queries are not available: cyan, cyan50",
                 aachen_color(c("red", "cyan")),
                 "The following queries are not available: cyan")
})
