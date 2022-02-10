#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("sim_realistic-geometries")
# setwd("src/sim_realistic-geometries")

#' Grid

#' Create grid geometry
geometry <- create_sf_grid(height = 6, width = 6)
grid <- sf::st_sf(geometry)

#' Check grid geometry
pdf("grid.pdf", h = 5, w = 6.25)
plot(grid)
dev.off()

#' Save a copy of the geometry
saveRDS(grid, "grid.rds")

#' Simulate and save IID, ICAR and IK data
sim_iid(grid, nsim) %>% saveRDS("data_iid_grid.rds")
sim_icar(grid, nsim) %>% saveRDS("data_icar_grid.rds")
sim_ik(grid, L = 100, nsim, l = 2.5) %>% saveRDS("data_ik_grid.rds")

#' Cote d'Ivoire

#' Create Cote d'Ivoire geometry
civ <- ci %>% select(geometry)
sf::st_crs(civ) <- NA

#' Check the geometry
pdf("civ.pdf", h = 5, w = 6.25)
plot(civ)
dev.off()

#' Save a copy of the geometry
saveRDS(civ, "civ.rds")

#' Simulate and save IID, ICAR and IK data
sim_iid(civ, nsim) %>% saveRDS("data_iid_civ.rds")
sim_icar(civ, nsim) %>% saveRDS("data_icar_civ.rds")
sim_ik(civ, L = 100, nsim, l = 2.5) %>% saveRDS("data_ik_civ.rds")

#' Texas

#' Create geometry
#' Texas data from https://gis-txdot.opendata.arcgis.com/datasets/texas-us-house-districts
#' Download > Shapefile > Unzip to texas/ folder
geometry <- sf::st_geometry(sf::st_read("texas/U_S__House_District.shp"))
tex <- sf::st_sf(geometry)
sf::st_crs(tex) <- NA

#' Check the geometry
pdf("tex.pdf", h = 5, w = 6.25)
plot(tex)
dev.off()

#' Save a copy of the geometry
saveRDS(tex, "tex.rds")

#' Simulate and save IID, ICAR and IK data
sim_iid(tex, nsim) %>% saveRDS("data_iid_tex.rds")
sim_icar(tex, nsim) %>% saveRDS("data_icar_tex.rds")
sim_ik(tex, L = 100, nsim, l = 2.5) %>% saveRDS("data_ik_tex.rds")
