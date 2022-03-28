# orderly::orderly_develop_start("check_ik-compute")
# setwd("src/check_ik-compute")

#' Checking that the Stan code to calculate the integrated kernel is correct

sf <- mw
L <- 10
type = "random"

n <- nrow(sf)
samples <- sf::st_sample(sf, type = type, exact = TRUE, size = rep(L, n))
S <- sf::st_distance(samples, samples)
sample_index <- sf::st_intersects(sf, samples)
sample_lengths <- lengths(sample_index)
start_index <- sapply(sample_index, function(x) x[1])

#' First calculate it directly using R only
D <- sf::st_distance(samples, samples)
kD <- matern(D, l = 1)
K <- matrix(nrow = n, ncol = n)

for(i in 1:n) {
  K[i, i] <- mean(kD[sample_index[[i]], sample_index[[i]]])
}

for(i in 1:(n - 1)) {
  for(j in (i + 1):n) {
    K[i, j] <- mean(kD[sample_index[[i]], sample_index[[j]]]) #' Fill the upper triangle
    K[j, i] <- K[i, j] #' Fill the lower triangle
  }
}

cov_r <- K

#' Now calculate it in Stan via two different methods
#' rstan::expose_stan_functions puts the C++ functions into the R local workspace to use
rstan::expose_stan_functions("cov_sample_average.stan")

#' 1. Newer method
cov_stan <- cov_sample_average(
  S = S,
  l = 1,
  n = n,
  start_index = start_index,
  sample_lengths = sample_lengths,
  total_samples = sum(sample_lengths)
)

#' 2. Old method
cov_stan_old <- cov_sample_average_old(
  n = n,
  L = 10,
  l = 1,
  S = S
)

#' Comparison (these statements should all be TRUE)
all.equal(cov_r, cov_stan)
all.equal(cov_r, cov_stan_old)
all.equal(cov_stan, cov_stan_old)

#' Hard to tell from an image if something is identical but anyway
pdf("cov-comparison.pdf", h = 5, w = 6.25)

cowplot::plot_grid(
  plot_matrix(cov_r) + labs(title = "R"),
  plot_matrix(cov_stan_old) + labs(title = "Stan old"),
  plot_matrix(cov_stan) + labs(title = "Stan new"),
  ncol = 2
)

dev.off()
