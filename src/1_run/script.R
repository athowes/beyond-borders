#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_run", parameters = list(f = "ik_aghq"))
# setwd("src/1_run")

geometries <- c()
if(vignette) geometries <- c(geometries, as.character(1:4))
if(realistic) geometries <- c(geometries, c("grid", "civ", "tex"))
if(length(geometries) == 0) stop("Either vignette or realistic must be TRUE")

sim_models <- c("iid", "icar", "ik")
fs <- list(get(f, envir = asNamespace("arealutils")))

pars <- expand.grid("geometry" = geometries, "sim_model" = sim_models, "inf_function" = fs)

#' Run models and assessment
results <- purrr::pmap(pars, run, .progress = TRUE)
results <- data.frame(dplyr::bind_rows(results))
results$inf_model <- f

saveRDS(results, "results.rds")
