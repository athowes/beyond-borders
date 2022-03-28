#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("sim_vignette-geometries")
# setwd("src/sim_vignette-geometries")

#' Import geometries
geometry_1 <- readRDS("depends/geometry-1.rds")
geometry_2 <- readRDS("depends/geometry-2.rds")
geometry_3 <- readRDS("depends/geometry-3.rds")
geometry_4 <- readRDS("depends/geometry-4.rds")

#' Geometry 1
sim_iid(geometry_1, nsim) %>% saveRDS("data_iid_1.rds")
sim_icar(geometry_1, nsim) %>% saveRDS("data_icar_1.rds")
sim_ik(geometry_1, L = 100, nsim, l = 2.5) %>% saveRDS("data_ik_1.rds")

#' Geometry 2
sim_iid(geometry_2, nsim) %>% saveRDS("data_iid_2.rds")
sim_icar(geometry_2, nsim) %>% saveRDS("data_icar_2.rds")
sim_ik(geometry_2, L = 100, nsim, l = 2.5) %>% saveRDS("data_ik_2.rds")

#' Geometry 3
sim_iid(geometry_3, nsim) %>% saveRDS("data_iid_3.rds")
sim_icar(geometry_3, nsim) %>% saveRDS("data_icar_3.rds")
sim_ik(geometry_3, L = 100, nsim, l = 2.5) %>% saveRDS("data_ik_3.rds")

#' Geometry 4
sim_iid(geometry_4, nsim) %>% saveRDS("data_iid_4.rds")
sim_icar(geometry_4, nsim) %>% saveRDS("data_icar_4.rds")
sim_ik(geometry_4, L = 100, nsim, l = 2.5) %>% saveRDS("data_ik_4.rds")
