synthetic <- function(sf, phi_list) {
  sim_list <- lapply(phi_list, function(phi) {
    phi <- as.numeric(phi)
    n <- nrow(sf)
    m <- rep(25, n)
    x <- -2 + phi
    rho <- plogis(x)
    y <- rbinom(n, m, rho)
    sf <- st_sf(y_obs = y, n_obs = m, geometry =  sf$geometry)
    return(list(sf = sf, rho = rho, x = x, phi = phi))
  })
}

sim_iid <- function(sf, nsim) {
  n <- nrow(sf)
  phi_df <- MASS::mvrnorm(n = nsim, mu = rep(0, n), Sigma = diag(n))
  phi_list <- rows_to_list(phi_df)
  synthetic(sf, phi_list)
}

sim_icar <- function(sf, nsim, save = TRUE) {
  nb <- sf_to_nb(sf$geometry)
  g <- nb_to_graph(nb)

  dat <- list(
    n = length(sf$geometry),
    n_edges = g$n_edges,
    node1 = g$node1,
    node2 = g$node2
  )

  fit <- rstan::stan(
    file = "icar.stan",
    data = dat,
    warmup = nsim * 2,
    iter = nsim * 52,
    chains = 1,
    thin = 50
  )

  phi_df <- rstan::extract(fit)$phi
  phi_list <- rows_to_list(phi_df)
  synthetic(sf, phi_list)
}

sim_ik <- function(sf, L, nsim, save = TRUE, ...) {
  K <- integrated_covariance(sf, L = L, kernel = matern, type = "random", ...)
  K_scaled <- K / riebler_gv(K)
  phi_df <- MASS::mvrnorm(n = nsim, mu = rep(0, nrow(sf)), Sigma = K_scaled)
  phi_list <- rows_to_list(phi_df)
  synthetic(sf, phi_list)
}
