#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_ic", parameters = list(f = "iid_aghq"))
# setwd("src/2_ic")

surveys <- list("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")
fs <- list(get(f, envir = asNamespace("arealutils")))

#' Information criteria and regular fitting
run_ic <- function(survey, type, inf_function) {
  message("Begin fitting of ", f, " to the survey ", toupper(survey))
  sf <- readRDS(paste0("depends/", survey, ".rds"))
  capture.output(fit <- inf_function(sf, ii = NULL))
  samples <- aghq::sample_marginal(fit, M = 1000)
  x_samples <- samples$samps
  u_samples <- x_samples[rownames(x_samples) == "u", ]
  beta_0_samples <- x_samples[1, ]
  rho_samples <- plogis(u_samples + beta_0_samples)
  rho_summaries <- data.frame(t(apply(rho_samples, 1, function(x) c(mean(x), quantile(x, c(0.5, 0.025, 0.975))))), row.names = NULL)
  names(rho_summaries) <- c("mean", "mode", "lower", "upper")
  result <- bind_cols(select(sf, survey_id, area_name, y, n_obs), rho_summaries)
  result$inf_model <- f
  return(list(df = result, fit = fit))
}

ic_pars <- expand.grid("survey" = surveys, "inf_function" = fs)
ic <- purrr::pmap(ic_pars, safely(run_ic))

saveRDS(ic, file = "ic.rds")
