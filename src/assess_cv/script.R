#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("assess_cv")
# setwd("src/assess_cv")

inf_models <- c("constant_inla")
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

purrr::pmap_df(pars, function(inf_model, survey) {
  fit <- readRDS(paste0("depends/fit_", substr(survey, 1, 3), "_", inf_model, ".rds"))
  data.frame(survey = survey, inf_model = inf_model) %>%
    mutate(
      dic = fit$dic$dic,
      waic = fit$waic$waic,
      cpo = sum(fit$cpo$cpo)
    )
})
