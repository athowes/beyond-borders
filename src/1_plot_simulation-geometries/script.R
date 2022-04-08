#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_plot_simulation-geometries")
# setwd("src/1_plot_simulation-geometries")

df <- bind_rows(
  data.frame(name = "Grid", type = "Realistic", geometry = readRDS("depends/grid.rds")),
  data.frame(name = "Cote d'Ivoire", type = "Realistic", geometry = readRDS("depends/civ.rds")),
  data.frame(name = "Texas", type = "Realistic", geometry = readRDS("depends/tex.rds")),
  data.frame(name = "Base", type = "Vignette", geometry = readRDS("depends/geometry-1.rds")),
  data.frame(name = "Circles", type = "Vignette", geometry = readRDS("depends/geometry-2.rds")),
  data.frame(name = "Triangle", type = "Vignette", geometry = readRDS("depends/geometry-3.rds")),
  data.frame(name = "Widths", type = "Vignette", geometry = readRDS("depends/geometry-4.rds")),
) %>%
  st_as_sf()

pdf(file = "simulation-geometries.pdf", height = 4, width = 6.25)

plots <- df %>%
  split(~name) %>%
  lapply(function(x) {
    ggplot(x) +
      geom_sf() +
      theme_minimal() +
      theme_void()
  })

top_row <- cowplot::plot_grid(plots[["Base"]],  plots[["Triangle"]], plots[["Widths"]], plots[["Circles"]], nrow = 1)
bottom_row <- cowplot::plot_grid(plots[["Grid"]], plots[["Cote d'Ivoire"]], plots[["Texas"]], nrow = 1)

cowplot::plot_grid(top_row, bottom_row, nrow = 2)

dev.off()

ggsave(
  "simulation-geometries.png",
  cowplot::plot_grid(top_row, bottom_row, nrow = 2),
  width = 6.25, height = 4, units = "in", dpi = 300
)
