#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_cv_constant-inla")
# setwd("src/2_cv_constant-inla")

surveys <- list("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")
types <- list("loo", "sloo")
fs <- list(bsae::constant_inla)
pars <- expand.grid("survey" = surveys, "f" = fs)
cv_pars <- expand.grid("survey" = surveys, "type" = types, "f" = fs)

purrr::pmap(cv_pars, bsae:::run_cv_models)
purrr::pmap(pars, bsae:::run_models)
