#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("assess_cv")
# setwd("src/assess_cv")

inf_models <- c("constant_inla", "iid_inla", "besag_inla", "bym2_inla")
# inf_models <- c("constant_inla", "iid_inla", "besag_inla", "bym2_inla", "fck_inla", "fik_inla", "ck_stan", "ik_stan")
surveys <- c("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")
types <- c("loo", "sloo")

#' Direct model fit measures (DIC, WAIC and CPO)
pars <- expand.grid(
  "inf_model" = inf_models,
  "survey" = surveys
)

direct <- purrr::pmap_df(pars, function(inf_model, survey) {
  fit <- readRDS(paste0("depends/fit_", substr(survey, 1, 3), "_", inf_model, ".rds"))
  data.frame(dic = fit$dic$local.dic, waic = fit$waic$local.waic, cpo = fit$cpo$cpo) %>%
    tibble::rownames_to_column("id") %>%
    mutate(
      survey = survey,
      inf_model = inf_model,
      .before = id
    ) %>%
    mutate(id = as.numeric(id))
})

saveRDS(direct, "direct.rds")

#' Bind all of the direct fits together

df_models <- purrr::pmap_df(pars, function(inf_model, survey) {
  fit <- readRDS(paste0("depends/fit_", substr(survey, 1, 3), "_", inf_model, ".rds"))
  st_read(paste0("depends/", survey, ".geojson")) %>%
    select(survey_id, area_id, area_name, geometry) %>%
    mutate(
      inf_model = inf_model,
      estimate = fit$summary.fitted.values$mean,
      ci_lower = fit$summary.fitted.values$`0.025quant`,
      ci_upper = fit$summary.fitted.values$`0.975quant`,
      .before = geometry
    )
})

df_raw <- purrr::pmap_df(list(surveys), function(survey) {
  st_read(paste0("depends/", survey, ".geojson")) %>%
    select(survey_id, area_id, area_name, estimate, ci_lower, ci_upper, geometry) %>%
    mutate(
      inf_model = "raw",
      .before = estimate
    )
})

df <- bind_rows(df_models, df_raw)

saveRDS(df, "df.rds")

#' Manual cross-validation model fit measures
#' Direct model fit measures (DIC, WAIC and CPO)
pars <- expand.grid(
  "inf_model" = inf_models,
  "survey" = surveys,
  "type" = types
)

manual <- purrr::pmap_df(pars, function(inf_model, survey, type) {
  fits <- readRDS(paste0("depends/fits_", substr(survey, 1, 3), "_", type, "_", inf_model, ".rds"))
  sf <- st_read(paste0("depends/", survey, ".geojson"))
  lapply(fits, function(x) held_out_metrics(fit = x$fit, sf = sf, i = x$predict_on, S = 1000)) %>%
    dplyr::bind_rows(.id = "id") %>%
    as.data.frame() %>%
    mutate(
      survey = survey,
      inf_model = inf_model,
      .before = id
    ) %>%
    mutate(id = as.numeric(id))
})

saveRDS(manual, "manual.rds")
