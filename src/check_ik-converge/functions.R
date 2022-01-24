adapted_integrated_covariance <- function(samples) {
  sample_index <- sf::st_intersects(grid, samples)
  D <- sf::st_distance(samples, samples)
  kD <- matern(D, l = 1)
  K <- matrix(nrow = n, ncol = n)
  #' Diagonal entries
  for(i in 1:(n - 1)) {
    K[i, i] <- mean(kD[sample_index[[i]], sample_index[[i]]])
    for(j in (i + 1):n) {
      #' Off-diagonal entries
      K[i, j] <- mean(kD[sample_index[[i]], sample_index[[j]]]) #' Fill the upper triangle
      K[j, i] <- K[i, j] #' Fill the lower triangle
    }
  }
  K[n, n] <- mean(kD[sample_index[[n]], sample_index[[n]]])
  return(K)
}

plot_samples <- function(samples){
  ggplot(grid) +
    geom_sf(fill = "lightgrey") +
    geom_sf(data = samples, alpha = 0.5, shape = 4) +
    labs(x = "Longitude", y = "Latitude") +
    theme_minimal() +
    labs(subtitle = paste0(length(samples$geom), " samples"), fill = "") +
    theme(axis.title = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank())
}

#' Simple metric between matrices of identical dimension
frobenius <- function(M1, M2) {
  diff <- M1 - M2
  sqrt(sum(diff^2))
}

int_convergence_experiment <- function(L, n_sim = 100) {
  sample_sets <- lapply(1:n_sim, function(i) sf::st_sample(grid, type = type, exact = TRUE, size = rep(L, n)))
  covs <- lapply(sample_sets, adapted_integrated_covariance)
  frobs <- sapply(covs, function(cov) frobenius(gt_cov, cov))
  return(frobs)
}
