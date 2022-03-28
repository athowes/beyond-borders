rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

sf <- mw

centroid_distance <- function(sf) {
  cent <- sf::st_centroid(sf)
  D <- sf::st_distance(cent, cent)
  return(D)
}

D <- centroid_distance(sf)

dat <- list(n = nrow(sf),
            y = sf$y,
            m = sf$n_obs,
            mu = rep(0, nrow(sf)),
            D = D)

nsim_warm <- 100
nsim_iter <- 1000

fit <- rstan::stan("centroid.stan",
                   data = dat,
                   warmup = nsim_warm,
                   iter = nsim_iter)

saveRDS(fit, file = "centroid.rds")
