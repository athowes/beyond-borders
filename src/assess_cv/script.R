#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("assess_cv")
# setwd("src/assess_cv")

inf_models <- c("constant_inla", "iid_inla", "besag_inla", "bym2_inla")
# inf_models <- c("constant_inla", "iid_inla", "besag_inla", "bym2_inla", "fck_inla", "fik_inla", "ck_stan", "ik_stan")
surveys <- c("civ2017phia", "mwi2016phia")
# surveys <- c("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")
types <- c("loo")
# types <- c("loo", "sloo")

#' Direct model fit measures (DIC, WAIC and CPO)
pars <- expand.grid(
  "inf_model" = inf_models,
  "survey" = surveys
)

direct <- purrr::pmap_df(pars, function(inf_model, survey) {
  fit <- readRDS(paste0("depends/fit_", substr(survey, 1, 3), "_", inf_model, ".rds"))
  data.frame(survey = survey, inf_model = inf_model) %>%
    mutate(
      dic = fit$dic$dic,
      waic = fit$waic$waic,
      cpo = sum(fit$cpo$cpo)
    )
})

#' Manual cross-validation model fit measures
#' Direct model fit measures (DIC, WAIC and CPO)
pars <- expand.grid(
  "inf_model" = inf_models,
  "survey" = surveys,
  "type" = types
)

manual <- purrr::pmap_df(pars, function(inf_model, survey, type) {
  fits <- readRDS(paste0("depends/fits_", substr(survey, 1, 3), "_", type, "_", inf_model, ".rds"))
  df <- st_read(paste0("depends/", survey, ".geojson"))
  sapply(fits, function(x) held_out_metrics(fit = x$fit, sf = df, i = x$predict_on, S = 1000)) %>%
    t() %>%
    data.frame() %>%
    mutate(
      survey = survey,
      inf_model = inf_model,
      .before = id
    )
})

saveRDS(direct, "direct.rds")
saveRDS(manual, "manual.rds")
