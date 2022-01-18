#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_integration-method")
# setwd("src/plot_integration-method")

#' The number of points in each area
L <- 10

#' The number of areas
n <- nrow(mw)

#' The different integration strategies
random <- sf::st_sample(mw, size = rep(L, n))
hexagonal <- sf::st_sample(mw, size = rep(L, n), type = "hexagonal", exact = TRUE)
regular <- sf::st_sample(mw, size = rep(L, n), type = "regular", exact = TRUE)

pdf("integration-method.pdf", h = 2.5, w = 6.25)

cowplot::plot_grid(
  plot_samples(random, title = "Random"),
  plot_samples(hexagonal, title = "Hexagonal"),
  plot_samples(regular, title = "Regular"),
  ncol = 3
)

dev.off()
