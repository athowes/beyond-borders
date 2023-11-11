#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_fit", parameters = list(f = "iid_aghq"))
# setwd("src/1_fit")

geometries <- c()
vignette_geometries <- as.character(1:4)
realistic_geometries <- c("grid", "civ", "tex")
if(vignette) geometries <- c(geometries, vignette_geometries)
if(realistic) geometries <- c(geometries, realistic_geometries)
if(length(geometries) == 0) stop("Either vignette or realistic must be TRUE")

sim_models <- c("iid", "icar", "ik")
fs <- list(get(f, envir = asNamespace("arealutils")))

pars <- expand.grid("geometry" = geometries, "sim_model" = sim_models, "f" = fs)

#' Prevent orderly complaining by generating all possible simulations
orderly_shush()

# Run models and save for each row of pars
pb <- progress_estimated(nrow(pars))
purrr::pmap(pars, run_models)
