#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_assess_lengthscale-marginal")
# setwd("src/1_assess_lengthscale-marginal")

geometries <- c("grid", "civ", "tex", as.character(1:4))
sim_models <- c("ik")

inf_models <- c("ck_stan")
# inf_models <- c("ck_stan", "ik_stan")

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

  #' CK models can't handle concentric circles
  if(geometry == "2" & inf_model %in% c("fck_inla", "ck_stan")) return(NULL)

  #' The fitted models
  fits_loc <- paste0("depends/fits_", sim_model, "_", geometry, "_", inf_model, ".rds")
  fits <- readRDS(fits_loc)

  #' Assess the lengthscale marginal
  df <- lapply(fits, assess_marginal_lengthscale, lengthscale = 5/2) %>%
    arealutils::list_to_df() %>%
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

df <- df %>%
  mutate(
    mse_mean = (obs - mean)^2,
    mae_mean = abs(obs - mean),
    mse_mode = (obs - mode)^2,
    mae_mode = abs(obs - mode)
  )

saveRDS(df, "df.rds")
