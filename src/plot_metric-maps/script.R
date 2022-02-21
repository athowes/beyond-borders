#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_metric-maps")
# setwd("src/plot_metric-maps")

#' Get geometries for mapping
civ <- readRDS("depends/civ.rds")
grid <- readRDS("depends/grid.rds")
tex <- readRDS("depends/tex.rds")
geometry_1 <- readRDS("depends/geometry-1.rds")
geometry_2 <- readRDS("depends/geometry-2.rds")
geometry_3 <- readRDS("depends/geometry-3.rds")
geometry_4 <- readRDS("depends/geometry-4.rds")

df_rho <- readRDS("depends/df_rho.rds")

produce_maps("civ", civ, "crps")
produce_maps("grid", grid, "crps")
produce_maps("tex", tex, "crps")
produce_maps("1", geometry_1, "crps")
produce_maps("2", geometry_2, "crps")
produce_maps("3", geometry_3, "crps")
produce_maps("4", geometry_4, "crps")
