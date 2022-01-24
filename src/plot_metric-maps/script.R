#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_metric-maps")
# setwd("src/plot_metric-maps")

#' Get geometries for mapping
civ <- readRDS("depends/geometry_civ.rds")
grid <- readRDS("depends/geometry_grid.rds")
tex <- readRDS("depends/geometry_tex.rds")

df_rho <- readRDS("depends/df_rho.rds")

#' CRPS map
pdf("crps-map-rho.pdf", h = 4, w = 6.25)

df_rho %>%
  update_naming() %>%
  group_mean_and_se(c("geometry", "sim_model", "inf_model", "id")) %>%
  metric_map(
    metric = "crps",
    g = "Grid",
    sf = grid
  )

dev.off()
