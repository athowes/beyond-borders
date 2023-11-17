summaries <- function(x, y) {
  list(
    "mean" = mean(x),
    "upper" = stats::quantile(x, 0.975),
    "lower" = stats::quantile(x, 0.025),
    "mse" = mean((x - y)^2),
    "crps" = arealutils::crps(x, y),
    "q" = stats::ecdf(x)(y),
    "truth" = y
  )
}

run <- function(geometry, sim_model, inf_function) {

  if(f %in% c("fck_aghq", "ck_aghq") & geometry == "2") {
    return(NULL)
  }

  data <- readRDS(paste0("depends/data_", sim_model, "_", geometry, ".rds"))

  message("Fitting ", length(data), " ", f, " models to ", sim_model, " simulated data on the ", geometry, " geometry...")

  results <- lapply(data, function(x) {
    capture.output(fit <- inf_function(x$sf))
    samples_aghq <- aghq::sample_marginal(fit, 100)
    x_samples <- samples_aghq$samps
    theta_samples <- do.call(rbind, samples_aghq$thetasamples)
    samples <- rbind(x_samples, theta_samples)

    true_values <- c(-2, x$u, log(1))
    if(f %in% c("ck_aghq", "ik_aghq")) {
      true_values <- c(true_values, log(2.5))
    }

    result <- purrr::map2_df(split(samples, seq(nrow(samples))), true_values, summaries)
    result$par <- c("beta_0", paste0("u", 1:length(x$u)), names(fit$optresults$mode))
    return(result)
  })

  df <- data.frame(dplyr::bind_rows(results, .id = "replicate"))
  df$geometry <- geometry
  df$sim_model <- sim_model

  return(df)
}
