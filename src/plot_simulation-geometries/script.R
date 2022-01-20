#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_simulation-geometries")
# setwd("src/plot_simulation-geometries")

grid <- readRDS("depends/geometry_grid.rds")
civ <- readRDS("depends/geometry_civ.rds")
tex <- readRDS("depends/geometry_tex.rds")

area_plot <- function(geometry, title) {
  ggplot(geometry) +
    geom_sf() +
    theme_minimal() +
    labs(subtitle = paste0(title)) +
    theme_void()
}

pdf(file = "simulation-geometries.pdf", height = 2.5, width = 6.75)

cowplot::plot_grid(
  area_plot(grid, "6 x 6 grid"),
  area_plot(ci, "33 districts, Cote d'Ivoire"),
  area_plot(tex, "36 congressional districts, Texas"),
  ncol = 3,
  align = "h"
)

dev.off()
