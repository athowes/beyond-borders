#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_simulation-geometries")
# setwd("src/plot_simulation-geometries")

grid <- readRDS("depends/grid.rds")
civ <- readRDS("depends/civ.rds")
tex <- readRDS("depends/tex.rds")
geometry_1 <- readRDS("depends/geometry-1.rds")
geometry_2 <- readRDS("depends/geometry-2.rds")
geometry_3 <- readRDS("depends/geometry-3.rds")
geometry_4 <- readRDS("depends/geometry-4.rds")

area_plot <- function(geometry, title) {
  ggplot(geometry) +
    geom_sf() +
    theme_minimal() +
    labs(subtitle = paste0(title)) +
    theme_void()
}

pdf(file = "simulation-geometries.pdf", height = 4.5, width = 6.25)

plotA <- cowplot::plot_grid(
  area_plot(geometry_1, "Base"),
  area_plot(geometry_2, "Concentric circles"),
  area_plot(geometry_3, "Trianglular"),
  area_plot(geometry_4, "Unequal widths"),
  ncol = 4,
  align = "h"
)

plotB <- cowplot::plot_grid(
  area_plot(grid, "6 x 6 grid"),
  area_plot(ci, "33 districts, Cote d'Ivoire"),
  area_plot(tex, "36 electoral districts, Texas"),
  ncol = 3,
  align = "h"
)

cowplot::plot_grid(
  plotA,
  plotB,
  ncol = 1,
  rel_heights = c(0.6, 1)
  # labels = "AUTO",
  # label_size = 12,
  # vjust = 0.5
)

dev.off()
