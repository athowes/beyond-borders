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
