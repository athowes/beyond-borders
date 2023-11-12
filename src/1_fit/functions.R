orderly_shush <- function() {
  lapply(
    expand.grid("sim_model" = sim_models, "geometry" = c(vignette_geometries, realistic_geometries)) %>%
      as.data.frame() %>%
      mutate(file = paste0("fits_", sim_model, "_", geometry, ".rds")) %>%
      pull(file),
    function(file) saveRDS(NULL, file)
  )
}

summaries <- function(x, y) {
  list("mse" = mean((x - y)^2), "crps" = arealutils::crps(x, y))
}

run <- function(geometry, sim_model, f) {
  if(deparse(substitute(f)) %in% c("fck_aghq", "ck_aghq") & geometry == "2") return(NULL)

  data <- readRDS(paste0("depends/data_", sim_model, "_", geometry, ".rds"))

  results <- lapply(data, function(x) {
    capture.output(fit <- f(x$sf))
    samples_aghq <- aghq::sample_marginal(fit, 100)
    samples <- samples_aghq$samps
    samples <- rbind(samples, unlist(samples_aghq$thetasamples))
    true_values <- c(-2, x$u, 0)
    result <- purrr::map2_df(split(samples, seq(nrow(samples))), true_values, summaries)
    result$par <- c("beta_0", paste0("u", 1:length(x$u)), names(fit$optresults$mode))
    return(result)
  })

  df <- data.frame(dplyr::bind_rows(results, .id = "replicate"))
  df$geometry <- geometry
  df$sim_model <- sim_model

  return(df)
}
