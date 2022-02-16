#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("cv_constant-inla")
# setwd("src/cv_constant-inla")

surveys <- c("civ2017phia", "mwi2016phia")
# surveys <- c("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")
types <- c("loo")
# types <- c("loo", "sloo")

pars <- expand.grid(
  "survey" = surveys,
  "type" = types
)

#' Function to run bsae::constant_inla for each cross-validation fold
run_cv_models <- function(survey, type) {
  sf <- read_csv(paste0("depends/", survey, ".csv"))
  training_sets <- create_folds(sf, type = toupper(type))

  print(paste0("Begin ", toupper(type), " cross-valdiation of ", toupper(survey)))
  pb <- progress_estimated(nrow(sf)) #' Initialise progress bar

  training_sets <- lapply(training_sets, function(training_set) {
    training_set$fit <- bsae::constant_inla(training_set$data)
    pb$tick()$print()
    return(training_set)
  })

  saveRDS(training_sets, file = paste0("fits_", substr(survey, 1, 3), "_", tolower(type), ".rds"))
}

#' Run models and save for each row of pars
purrr::pmap_df(pars, run_cv_models)
