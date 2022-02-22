#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("cv_iid-inla")
# setwd("src/cv_iid-inla")

surveys <- c("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")
types <- c("loo", "sloo")

pars <- expand.grid(
  "survey" = surveys,
  "type" = types
)

#' Function to run bsae::iid_inla for each cross-validation fold
run_cv_models <- function(survey, type) {
  sf <- st_read(paste0("depends/", survey, ".geojson"))
  training_sets <- create_folds(sf, type = toupper(type))

  print(paste0("Begin ", toupper(type), " cross-valdiation of ", toupper(survey)))
  pb <- progress_estimated(nrow(sf)) #' Initialise progress bar

  training_sets <- lapply(training_sets, function(training_set) {
    training_set$fit <- bsae::iid_inla(training_set$data)
    pb$tick()$print()
    return(training_set)
  })

  saveRDS(training_sets, file = paste0("fits_", substr(survey, 1, 3), "_", tolower(type), ".rds"))
}

#' Run models and save for each row of pars
purrr::pmap_df(pars, run_cv_models)

#' Function to run bsae::iid_inla for the whole dataset
#' This will be useful for comparing R-INLA and Stan inbuilt model comparison metrics to manual CV
run_models <- function(survey, type) {
  sf <- st_read(paste0("depends/", survey, ".geojson"))
  fit <- bsae::iid_inla(sf)
  saveRDS(fit, file = paste0("fit_", substr(survey, 1, 3), ".rds"))
}

purrr::pmap_df(expand.grid("survey" = surveys), run_models)
