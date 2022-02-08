#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("assess_intercept-marginal")
# setwd("src/assess_intercept-marginal")

geometries <- c("grid", "civ", "tex")
sim_models <- c("iid", "icar", "ik")

#' Currently we're testing with a subset, but in future it will seven different models
inf_models <- c("constant_inla", "besag_inla", "bym2_inla", "fck_inla", "fik_inla")
# inf_models <- c("constant_inla", "besag_inla", "bym2_inla", "fck_inla", "fik_inla", "ck_stan", "ik_stan")

pars <- expand.grid(
  "geometry" = geometries,
  "sim_model" = sim_models,
  "inf_model" = inf_models
)

#' Function to process fits
process_fits <- function(geometry, sim_model, inf_model) {

  message(
    "Beginning assessment of intercept posterior marginal of the ", inf_model,
    " model fit to ", sim_model, " data on the ", geometry, " geometry."
  )

  #' The fitted models
  fits_loc <- paste0("depends/fits_", sim_model, "_", geometry, "_", inf_model, ".rds")
  fits <- readRDS(fits_loc)

  #' Assess the intercept marginal
  df <- lapply(fits, assess_marginal_intercept, intercept = -2) %>%
    bsae::list_to_df() %>%
    #' Add columns for meta data
    mutate(
      geometry = geometry,
      sim_model = sim_model,
      inf_model = inf_model,
      .before = replicate
    )

  message("intercept parameter assessment complete.")

  return(df)
}

#' Eventually this will be iterated over geometries, sim_models and inf_models
df <- purrr::pmap_df(pars, process_fits)

saveRDS(df, "df.rds")
