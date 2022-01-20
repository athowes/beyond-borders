#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("assess_rho-marginals")
# setwd("src/assess_rho-marginals")

geometries <- c("grid", "civ", "tex")
sim_models <- c("iid", "icar", "ik")
inf_models <- c("constant_inla")

data <- readRDS("depends/data_icar_civ.rds")
fits <- readRDS("depends/fits_icar_civ_constant_inla.rds")

rho_df <- Map(assess_marginals_rho, lapply(data, "[[", "rho"), fits) %>%
  list_to_df()
