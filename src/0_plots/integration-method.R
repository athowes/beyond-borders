plot_samples <- function(samples, title){

  sf_lightgrey <- "#E6E6E6"
  cbpalette <- c("#56B4E9","#009E73", "#E69F00", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")

  ggplot(mw) +
    geom_sf(fill = sf_lightgrey) +
    geom_sf(data = samples, size = 0.5, col = cbpalette[1]) +
    labs(x = "", y = "") +
    theme_minimal() +
    labs(subtitle = title, fill = "") +
    theme_void()
}

#' The number of points in each area
L <- 10

#' The number of areas
n <- nrow(mw)

#' The different integration strategies
#' Note: sampling methods from package spatstat are interfaced!
#' https://cran.r-project.org/web/packages/spatstat/spatstat.pdf

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
