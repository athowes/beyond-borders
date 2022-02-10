#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("fit_besag-inla")
# setwd("src/fit_besag-inla")

vignette_geometries <- as.character(1:4)
realistic_geometries <- c("grid", "civ", "tex")

geometries <- c()
if(vignette) geometries <- c(geometries, vignette_geometries)
if(realistic) geometries <- c(geometries, realistic_geometries)
if(length(geometries) == 0) stop("Either vignette or realistic must be TRUE")

sim_models <- c("iid", "icar", "ik")

#' Geometry and simulation model
pars <- expand.grid(
  "geometry" = geometries,
  "sim_model" = sim_models
)

#' Function to run bsae::besag_inla
run_models <- function(geometry, sim_model) {
  data <- readRDS(paste0("depends/data_", sim_model, "_", geometry, ".rds"))
  fits <- lapply(data, function(x) bsae::besag_inla(x$sf))
  saveRDS(fits, file = paste0("fits_", sim_model, "_", geometry, ".rds"))
}

# Run models and save for each row of pars
purrr::pmap_df(pars, run_models)
