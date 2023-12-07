#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_cv", parameters = list(f = "fik_aghq"))
# setwd("src/2_cv")

surveys <- list("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")
fs <- list(get(f, envir = asNamespace("arealutils")))

#' Cross-validation
run_cv <- function(survey, inf_function) {
  message("Begin ", toupper(type), " cross-valdiation of ", f, " to the survey ", toupper(survey))
  sf <- readRDS(paste0("depends/", survey, ".rds"))

  result <- lapply(1:nrow(sf), function(ii) {
    capture.output(fit <- inf_function(sf, ii_mis = ii - 1))
    samples <- aghq::sample_marginal(fit, M = 1000)
    x_samples <- samples$samps
    beta_0_samples <- x_samples[1, ]
    u_samples <- x_samples[1 + ii, ]
    rho_samples <- plogis(u_samples + beta_0_samples)
    summaries <- function(x) c(mean(x), quantile(x, c(0.5, 0.025, 0.975)))
    rho_summaries <- summaries(rho_samples)
    out <- c(rho_summaries, ii)
    names(out) <- c("mean", "mode", "lower", "upper", "index")
    return(out)
  })

  result <- bind_rows(result)
  result$inf_model <- f
  result$survey <- survey
  return(result)
}

cv_pars <- expand.grid("survey" = surveys, "inf_function" = fs)
cv <- purrr::pmap(cv_pars, safely(run_cv))

saveRDS(cv, file = "cv.rds")

#' Information criteria and regular fitting
run_ic <- function(survey, type, inf_function) {
  message("Begin fitting of ", f, " to the survey ", toupper(survey))
  sf <- readRDS(paste0("depends/", survey, ".rds"))
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
