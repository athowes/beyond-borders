#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("assess_time-taken")
# setwd("src/assess_time-taken")

geometries <- c("grid", "civ", "tex")
sim_models <- c("iid", "icar", "ik")

#' Currently we're testing with a subset, but in future it will seven different models
inf_models <- c("constant_inla", "iid_inla", "besag_inla", "bym2_inla", "fck_inla", "fik_inla")
# inf_models <- c("constant_inla", "iid_inla", "besag_inla", "bym2_inla", "fck_inla", "fik_inla", "ck_stan", "ik_stan")

pars <- expand.grid(
  "geometry" = geometries,
  "sim_model" = sim_models,
  "inf_model" = inf_models
)

#' Initialise progress bar
pb <- progress_estimated(nrow(pars))

#' Function to process fits
process_fits <- function(geometry, sim_model, inf_model) {
  pb$tick()$print()

  #' The fitted models
  fits_loc <- paste0("depends/fits_", sim_model, "_", geometry, "_", inf_model, ".rds")
  fits <- readRDS(fits_loc)

  #' Assess the intercept marginal
  df <- lapply(fits, function(fit) list(t = get_time(fit))) %>%
    bsae::list_to_df() %>%
    #' Add columns for meta data
    mutate(
      geometry = geometry,
      sim_model = sim_model,
      inf_model = inf_model,
      .before = replicate
    )

  return(df)
}

#' Eventually this will be iterated over geometries, sim_models and inf_models
df <- purrr::pmap_df(pars, process_fits)

saveRDS(df, "df.rds")
