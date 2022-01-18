#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("sim_tex")
# setwd("src/sim_tex")

#' Create geometry
#' Texas data from https://gis-txdot.opendata.arcgis.com/datasets/texas-us-house-districts
#' Download > Shapefile > Unzip to texas/ folder
geometry <- sf::st_geometry(sf::st_read("texas/U_S__House_District.shp"))
tex <- sf::st_sf(geometry)
sf::st_crs(tex) <- NA

#' Check the geometry
pdf("geometry.pdf", h = 5, w = 6.25)
plot(tex)
dev.off()

#' Save a copy of the geometry
saveRDS(tex, "geometry.rds")

#' Simulate and save IID data
data_iid <- sim_iid(tex, nsim)
saveRDS(data_iid, "data_iid.rds")

#' Simulate and save ICAR data
data_icar <- sim_icar(tex, nsim)
saveRDS(data_icar, "data_icar.rds")

#' Simulate and save IK data
data_ik <- sim_ik(tex, L = 100, nsim, l = 2.5)
saveRDS(data_ik, "data_ik.rds")
