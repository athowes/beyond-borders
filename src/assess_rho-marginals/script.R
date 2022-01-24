#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("assess_rho-marginals")
# setwd("src/assess_rho-marginals")

geometries <- c("grid", "civ", "tex")
sim_models <- c("iid", "icar", "ik")

#' Currently we're testing with just the one constant model, but in future it will seven different models
inf_models <- c("constant_inla")
# inf_models <- c("constant_inla", "besag_inla", "bym2_inla", "fck_inla", "fik_inla", "ck_stan", "ik_stan")

#' Function to process fits
process_fits <- function(geometry, sim_model, inf_model) {
  #' The underlying truth
  data_loc <- paste0("depends/data_", sim_model, "_", geometry, ".rds")
  data <- readRDS(data_loc)

  #' The fitted models
  fits_loc <- paste0("depends/fits_", sim_model, "_", geometry, "_", inf_model, ".rds")
  fits <- readRDS(fits_loc)

  #' Assess the rho marginals
  rhos <- lapply(data, "[[", "rho")
  Map(assess_marginals_rho, rhos, fits) %>%
    bsae::list_to_df() %>%
    #' Add columns for meta data
    mutate(
      geometry = geometry,
      sim_model = sim_model,
      inf_model = inf_model,
      .before = replicate
    )
}

#' Eventually this will be iterated over geometries, sim_models and inf_models
#' But keeping it simple now to keep things moving (learning my lessons!)
df <- process_fits("grid", "iid", "constant_inla")

saveRDS(df, "rho_df.rds")
