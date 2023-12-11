#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_cv", parameters = list(f = "iid_aghq"))
# setwd("src/2_cv")

types <- list("loo", "sloo")
surveys <- list("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")
fs <- list(get(f, envir = asNamespace("arealutils")))

#' Cross-validation
summaries <- function(x, y) {
  list(
    "mean" = mean(x),
    "upper" = stats::quantile(x, 0.975),
    "mode" = stats::quantile(x, 0.5),
    "lower" = stats::quantile(x, 0.025),
    "mse" = mean((x - y)^2),
    "crps" = arealutils::crps(x, y),
    "q" = stats::ecdf(x)(y),
    "truth" = y
  )
}

run_cv <- function(survey, type, inf_function) {
  message("Begin ", toupper(type), " cross-valdiation of ", f, " to the survey ", toupper(survey))

  if(type == "sloo") { return(NULL) } # Not implemented yet!

  sf <- readRDS(paste0("depends/", survey, ".rds"))

  result <- lapply(1:nrow(sf), function(ii) {
    capture.output(fit <- inf_function(sf, ii_mis = ii - 1))
    samples <- aghq::sample_marginal(fit, M = 1000)
    x_samples <- samples$samps
    beta_0_samples <- x_samples[1, ]
    u_samples <- x_samples[1 + ii, ]
    rho_samples <- plogis(u_samples + beta_0_samples)
    est <- sf$y[ii] / sf$n_obs[ii]
    out <- summaries(rho_samples, est)
    out[["index"]] <- ii
    return(out)
  })

  result <- bind_rows(result)
  result$inf_model <- f
  result$survey <- survey
  return(result)
}

cv_pars <- expand.grid("survey" = surveys, "type" = types, "inf_function" = fs)
cv <- purrr::pmap(cv_pars, safely(run_cv))
# cv <- bind_rows(lapply(cv, function(x) ifelse(is.null(x$error), x, NULL)))

saveRDS(cv, file = "cv.rds")

#' Information criteria and regular fitting
run_ic <- function(survey, type, inf_function) {
  message("Begin fitting of ", f, " to the survey ", toupper(survey))
  sf <- readRDS(paste0("depends/", survey, ".rds"))
  capture.output(fit <- inf_function(sf, ii_mis = NULL))
  samples <- aghq::sample_marginal(fit, M = 1000)
  x_samples <- samples$samps
  u_samples <- x_samples[rownames(x_samples) == "u", ]
  beta_0_samples <- x_samples[1, ]
  rho_samples <- plogis(u_samples + beta_0_samples)
  rho_summaries <- data.frame(t(apply(rho_samples, 1, function(x) c(mean(x), quantile(x, c(0.5, 0.025, 0.975))))), row.names = NULL)
  names(rho_summaries) <- c("mean", "mode", "lower", "upper")
  result <- bind_cols(select(sf, survey_id, area_name, y, n_obs), rho_summaries)
  result$inf_model <- f
  return(result)
}

ic_pars <- expand.grid("survey" = surveys, "inf_function" = fs)
ic <- purrr::pmap(ic_pars, safely(run_ic))

saveRDS(ic, file = "ic.rds")
