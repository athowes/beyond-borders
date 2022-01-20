#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("sim_civ")
# setwd("src/sim_civ")

#' Create geometry
civ <- ci %>% select(geometry)
sf::st_crs(civ) <- NA

#' Check the geometry
pdf("geometry.pdf", h = 5, w = 6.25)
plot(civ)
dev.off()

#' Save a copy of the geometry
saveRDS(civ, "geometry.rds")

#' Simulate and save IID data
data_iid <- sim_iid(civ, nsim)
saveRDS(data_iid, "data_iid.rds")

#' Simulate and save ICAR data
data_icar <- sim_icar(civ, nsim)
saveRDS(data_icar, "data_icar.rds")

#' Simulate and save IK data
data_ik <- sim_ik(civ, L = 100, nsim, l = 2.5)
saveRDS(data_ik, "data_ik.rds")
