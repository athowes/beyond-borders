#' Convert the rows of a dataframe to a list.
#'
#' @param df A dataframe.
rows_to_list <- function(df) {
  x <- as.list((data.frame(t(df))))
  names(x) <- NULL
  return(x)
}

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

sim_ck <- function(sf, nsim, ...) {
  K <- centroid_covariance(sf, ...)
  K_scaled <- K / riebler_gv(K)
  phi_df <- MASS::mvrnorm(n = nsim, mu = rep(0, nrow(sf)), Sigma = K_scaled)
  phi_list <- rows_to_list(phi_df)
  list <- synthetic(sf, phi_list)
  return(list)
}
