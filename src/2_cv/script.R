#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_cv", parameters = list(f = "fck_aghq"))
# setwd("src/2_cv")

surveys <- list("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")
fs <- list(get(f, envir = asNamespace("arealutils")))

#' Cross-validation
# run_cv <- function(survey, type, inf_function) {
#   message("Begin ", toupper(type), " cross-valdiation of ", f, " to the survey ", toupper(survey))
#   sf <- st_read(paste0("depends/", survey, ".geojson"))
#   training_sets <- bsae::create_folds(sf, type = toupper(type))
#
#   training_sets <- lapply(training_sets, function(x) {
#     x$fit <- inf_function(x$data)
#     return(x)
#   })
#
#   return(training_sets)
# }
#
# types <- list("loo", "sloo")
# cv_pars <- expand.grid("survey" = surveys, "type" = types, "inf_function" = fs)
# cv <- purrr::pmap(cv_pars, safely(run_cv))

saveRDS(NULL, file = "cv.rds")

#' Information criteria and regular fitting
run_ic <- function(survey, type, inf_function) {
  message("Begin fitting of ", f, " to the survey ", toupper(survey))
  sf <- st_read(paste0("depends/", survey, ".geojson"))
  fit <- inf_function(sf)
  samples <- aghq::sample_marginal(fit, M = 1000)
  x_samples <- samples$samps
  u_samples <- x_samples[rownames(x_samples) == "u", ]
  beta_0_samples <- x_samples[1, ]
  rho_samples <- plogis(u_samples + beta_0_samples)
  summaries <- function(x) c(mean(x), quantile(x, c(0.5, 0.025, 0.975)))
  rho_summaries <- data.frame(t(apply(rho_samples, 1, summaries)), row.names = NULL)
  names(rho_summaries) <- c("mean", "mode", "lower", "upper")
  result <- bind_cols(select(sf, survey_id, area_name, y, n_obs), rho_summaries)
  result$inf_model <- f
  return(result)
}

ic_pars <- expand.grid("survey" = surveys, "inf_function" = fs)
ic <- purrr::pmap(ic_pars, safely(run_ic))

saveRDS(ic, file = "ic.rds")
