rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

sf <- mw

# The number of integration points within each area
L <- 10

# The method for selecting integration points
type <- "hexagonal"

# The number of areas
n <- nrow(sf)

# Draw L samples from each area according to method type
samples <- sf::st_sample(sf, type = type, size = rep(L, n))

plot_samples <- function(samples){
  ggplot(sf) +
    geom_sf(fill = "lightgrey") +
    geom_sf(data = samples, alpha = 0.5, shape = 4) +
    labs(x = "Longitude", y = "Latitude") +
    theme_minimal() +
    labs(fill = "") +
    theme(axis.title = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank())
}

plot_samples(samples)

# Construct an (L * n) * (L * n) matrix containing the Euclidean distance between each sample
# Note that this ^ will not be exact for some settings of type (hexagonal, regular)
S <- sf::st_distance(samples, samples)
dim(S)

# Data structure for unequal number of points in each area
sample_index <- sf::st_intersects(sf, samples)
sample_lengths <- lengths(sample_index)
start_index <- sapply(sample_index, function(x) x[1])

dat <- list(n = nrow(sf),
            y = sf$y,
            m = sf$n_obs,
            mu = rep(0, nrow(sf)),
            sample_lengths = sample_lengths,
            total_samples = sum(sample_lengths),
            start_index = start_index,
            S = S)

fit <- rstan::stan("integrated.stan",
                   data = dat,
                   warmup = nsim_warm,
                   iter = nsim_iter)

saveRDS(fit, file = "integrated.rds")
