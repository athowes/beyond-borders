experiment <- function(nsim, n, phi_mean, phi_sd, y_sample_size) {
  phi <- rnorm(n, phi_mean, phi_sd)
  rho <- plogis(phi)
  m <- rep(y_sample_size, n)

  #' Without aggregation
  y <- replicate(nsim, rbinom(n, m, rho), simplify = FALSE)
  y <- lapply(y, sum)

  #' With aggregation (at the level of the latent field)
  y_agg <- replicate(nsim, rbinom(1, sum(m), weighted.mean(rho)), simplify = FALSE)

  return(list(y = unlist(y), y_agg = unlist(y_agg), phi = phi, rho = rho))
}

plot_hist <- function(result) {
  data.frame(
    type = c(rep("No aggregation (truth)", nsim), rep("Aggregation (approximation)", nsim)),
    y = c(result$y, result$y_agg)
  ) %>%
    ggplot() +
    geom_histogram(aes(x = y, fill = type), alpha = 0.5, position = "identity") +
    theme_minimal() +
    theme(
      legend.position = "bottom"
    )
}
