orderly_shush <- function() {
  lapply(
    expand.grid("sim_model" = sim_models, "geometry" = c(vignette_geometries, realistic_geometries)) %>%
      as.data.frame() %>%
      mutate(file = paste0("fits_", sim_model, "_", geometry, ".rds")) %>%
      pull(file),
    function(file) saveRDS(NULL, file)
  )
}

run_models <- function(geometry, sim_model, f) {
  pb$tick()$print()

  #' This model can't handle the concentric circles case!
  if(deparse(substitute(f)) %in% c("fck_inla", "ck_stan") & geometry == "2") return(NULL)

  data <- readRDS(paste0("depends/data_", sim_model, "_", geometry, ".rds"))

  fits <- lapply(data, function(x) {
    fit <- f(x$sf)
    if("inla" %in% class(fit)) {
      samples <- INLA::inla.posterior.sample(n = 1000, fit)
      fit[["samples"]] <- samples
      class(fit) <- "inlax"
    }
    return(fit)
  })

  saveRDS(fits, file = paste0("fits_", sim_model, "_", geometry, ".rds"))
}
