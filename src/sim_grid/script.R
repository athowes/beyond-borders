#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("sim_grid")
# setwd("src/sim_grid")

#' Create geometry
geometry <- create_sf_grid(height = 6, width = 6)
grid <- sf::st_sf(geometry)

#' Check the geometry
pdf("geometry.pdf", h = 5, w = 6.25)
plot(grid)
dev.off()

#' Save a copy of the geometry
saveRDS(grid, "geometry.rds")

#' Simulate and save IID data
data_iid <- sim_iid(grid, nsim)
saveRDS(data_iid, "data_iid.rds")

#' Simulate and save ICAR data
data_icar <- sim_icar(grid, nsim)
saveRDS(data_icar, "data_icar.rds")

#' Simulate and save IK data
data_ik <- sim_ik(grid, L = 100, nsim, l = 2.5)
saveRDS(data_ik, "data_ik.rds")
