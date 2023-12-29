#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_run", parameters = list(f = "ck_aghq", nsim = 10))
# setwd("src/1_run")

geometries <- c()
if(vignette) geometries <- c(geometries, as.character(1:4))
if(realistic) geometries <- c(geometries, c("grid", "civ", "tex"))
if(length(geometries) == 0) stop("Either vignette or realistic must be TRUE")

sim_models <- c("iid", "icar", "ik")
fs <- list(get(f, envir = asNamespace("arealutils")))

pars <- expand.grid("geometry" = geometries, "sim_model" = sim_models, "inf_function" = fs)

#' Run models (safely!) and assessment
results <- purrr::pmap(pars, safely(run), .progress = TRUE)

#' Save the errors
errors <- results %>%
  keep(~!is.null(.x$error))

saveRDS(errors, "errors.rds")

#' Save the results
results <- results %>%
  keep(~is.null(.x$error)) %>%
  map("result") %>%
  bind_rows() %>%
  data.frame()

results$inf_model <- f

saveRDS(results, "results.rds")
