# orderly::orderly_develop_start("check_plausible-lengthscale")
# setwd("src/check_plausible-lengthscale")

#' Checking the average distances between centroids in order to chose a plausible lengthscale to recover

grid <- readRDS("depends/geometry_grid.rds")
civ <- readRDS("depends/geometry_civ.rds")
tex <- readRDS("depends/geometry_tex.rds")

grid_distances <- c(centroid_distance(grid))
min(grid_distances[grid_distances > 0])

civ_distances <- c(centroid_distance(civ))
min(civ_distances[ci_distances > 0])

tex_distances <- c(centroid_distance(tex))
min(tex_distances[tex_distances > 0])

pdf("plausible-lengthscale.pdf", h = 6, w = 8)

cowplot::plot_grid(
  graph_length_plot(grid),
  ggplot() + geom_histogram(data = data.frame(x = grid_distances), aes(x = x))
)

cowplot::plot_grid(
  graph_length_plot(civ),
  ggplot() + geom_histogram(data = data.frame(x = civ_distances), aes(x = x))
)

cowplot::plot_grid(
  graph_length_plot(tex),
  ggplot() + geom_histogram(data = data.frame(x = tex_distances), aes(x = x))
)

dev.off()
