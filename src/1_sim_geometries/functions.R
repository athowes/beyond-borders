simulate_data <- function(u, sf) {
  n <- nrow(sf)
  m <- rep(25, n)
  u <- as.numeric(u)
  x <- -2 + u
  rho <- plogis(x)
  y <- rbinom(n, m, rho)
  sf <- st_sf(y_obs = y, n_obs = m, geometry =  sf$geometry)
  return(list(sf = sf, rho = rho, x = x, u = u))
}

sim_iid <- function(sf, nsim) {
  n <- nrow(sf)
  u_df <- MASS::mvrnorm(n = nsim, mu = rep(0, n), Sigma = diag(n))
  u_list <- rows_to_list(u_df)
  lapply(u_list, simulate_data, sf)
}

#' Note: This could be made more efficient

icar <- function(W, sd = 1) {
  n <- ncol(W)
  num <- rowSums(W)
  Q <- -W
  diag(Q) <- num
  Q_aux <- eigen(Q)$vectors[, order(eigen(Q)$values)]
  D_aux <- sort(eigen(Q)$values)
  u <- rnorm(n - 1, 0, sqrt(sd * (1 / D_aux[-1])))
  u <- Q_aux %*% c(0, u)
  return(as.vector(u))
}

sim_icar <- function(sf, nsim) {
  nb <- sf_to_nb(sf$geometry)
  W <- spdep::nb2mat(neighbours = nb, style = "B", zero.policy = TRUE)
  u_list <- lapply(1:nsim, function(i) icar(W))
  lapply(u_list, simulate_data, sf)
}

sim_ik <- function(sf, L, nsim, ...) {
  K <- integrated_covariance(sf, L = L, kernel = matern, type = "random", ...)
  K_scaled <- K / riebler_gv(K)
  u_df <- MASS::mvrnorm(n = nsim, mu = rep(0, nrow(sf)), Sigma = K_scaled)
  u_list <- rows_to_list(u_df)
  lapply(u_list, simulate_data, sf)
}
