run_cv_models <- function(survey, type, f) {
  sf <- st_read(paste0("depends/", survey, ".geojson"))
  training_sets <- bsae::create_folds(sf, type = toupper(type))

  print(paste0("Begin ", toupper(type), " cross-valdiation of ", toupper(survey)))
  pb <- progress_estimated(nrow(sf)) # Initialise progress bar

  training_sets <- lapply(training_sets, function(training_set) {
    training_set$fit <- f(training_set$data)
    pb$tick()$print()
    return(training_set)
  })

  saveRDS(training_sets, file = paste0("fits_", substr(survey, 1, 3), "_", tolower(type), ".rds"))
}

run_model <- function(survey, type, f) {
  sf <- st_read(paste0("depends/", survey, ".geojson"))
  fit <- f(sf)
  saveRDS(fit, file = paste0("fit_", substr(survey, 1, 3), ".rds"))
}
