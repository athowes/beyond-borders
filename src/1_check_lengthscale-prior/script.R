#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_check_lengthscale-prior")
# setwd("src/1_check_lengthscale-prior")

rstan::rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

data <- readRDS("depends/data_ik_grid.rds")
sf <- data[[1]]$sf

D <- centroid_distance(sf)
dat <- list(n = nrow(sf), y = sf$y, m = sf$n_obs, mu = rep(0, nrow(sf)), D = D)

# No prior on l (uniform): this shouldn't be a good idea
fit_non <- rstan::stan("stan/non-informative.stan", data = dat, iter = 2000)

# Nice visual checking tool: a lot of between chain posterior variability would be a bad sign
bayesplot::mcmc_hist_by_chain(fit_non, pars = "l")

# l ~ Gamma(1, 1)
fit_gamma <- rstan::stan("stan/gamma_.stan", data = dat, iter = 2000)

bayesplot::mcmc_hist_by_chain(fit_gamma, pars = "l")

# l ~ N+(0, (ub - lb) / 3): Half-normal with standard deviation geometry informed
# https://betanalpha.github.io/assets/case_studies/gp_part3/part3.html
dist <- as.vector(D)
lb <- min(dist) # Could do dist[dist > 0] here but results in lb = 1
lb <- 0.1
ub <- max(dist)
(ub - lb) / 3 # Approximately 2.3
fit_normal_data <- rstan::stan("stan/normal-data.stan", data = dat, iter = 2000)

bayesplot::mcmc_hist_by_chain(fit_normal_data, pars = "l")

# l ~ N(2.5, 1): Informative prior at the true value
fit_normal_inform <- rstan::stan("stan/informative.stan", data = dat, iter = 2000)

bayesplot::mcmc_hist_by_chain(fit_normal_inform, pars = "l")

# l ~ Inverse-Gamma(a, b): geometry informed
# https://warwick.ac.uk/fac/sci/statistics/crism/workshops/masterclassapril/presentation4.pdf

# Copied from brms (https://github.com/paul-buerkner/brms/commit/524e738aeeb82e49c5338839c3e10113763b6de1)
# plb: prior probability of being lower than minimum distance between points
# pub: prior probability of being higher than maximum distance between points
opt_fun <- function(x, lb, ub) {
  # optimize parameters on the log-scale to make them positive only
  x <- exp(x)
  y1 <- invgamma::pinvgamma(lb, x[1], x[2], log.p = TRUE)
  y2 <- invgamma::pinvgamma(ub, x[1], x[2], lower.tail = FALSE, log.p = TRUE)
  c(y1 - log(plb), y2 - log(pub))
}

plb <- 0.01
pub <- 0.01

opt_res <- nleqslv::nleqslv(
  c(0, 0), opt_fun, lb = lb, ub = ub,
  control = list(allowSingular = TRUE)
)

exp(opt_res$x) # Approximately a = 1.7, b = 0.6

fit_invgamma_data <- rstan::stan("stan/invgamma-data.stan", data = dat, iter = 2000)

bayesplot::mcmc_hist_by_chain(fit_invgamma_data, pars = "l")

fit_lognormal <- rstan::stan("stan/log-normal.stan", data = dat, iter = 2000)

bayesplot::mcmc_hist_by_chain(fit_lognormal, pars = "l")

cbpalette <- c("#56B4E9", "#009E73", "#E69F00", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")

# Prior comparison

fig_prior <- ggplot(data = data.frame(x = c(0, 5)), aes(x)) +
  stat_function(aes(col = "Gamma"), fun = dgamma, n = 301, args = list(1, 1)) +
  stat_function(aes(col = "Geometry-informed\nnormal"), fun = dnorm, n = 301, args = list(mean = 0, sd = 2.3)) +
  stat_function(aes(col = "Geometry-informed\ninverse-gamma"), fun = invgamma::dinvgamma, n = 301, args = list(1.7, 0.6)) +
  stat_function(aes(col = "Oracle normal"), fun = dnorm, n = 301, args = list(2.5, 1)) +
  stat_function(aes(col = "Non-informative"), fun = dunif, n = 301, args = list(0, 100)) +
  stat_function(aes(col = "Log-normal"), fun = dlnorm, n = 301, args = list(0, 1)) +
  labs(x = "Lengthscale", y = "Prior density", col = "", fill = "") +
  scale_color_manual(values = cbpalette) +
  theme_minimal() +
  geom_col(
    data = data.frame(
      x = rep(1, 6), y = rep(0, 6),
      type = as.factor(c("Gamma", "Geometry-informed\nnormal", "Geometry-informed\ninverse-gamma", "Oracle normal", "Non-informative", "Log-normal"))
    ),
    aes(x = x, y = y, fill = type)
  ) +
  scale_fill_manual(values = cbpalette) +
  guides(col = "none")

# Posterior comparison

models <- list(
  "Non-informative" = fit_non,
  "Gamma" = fit_gamma,
  "Geometry-informed\nnormal" = fit_normal_data,
  "Oracle normal" = fit_normal_inform,
  "Geometry-informed\ninverse-gamma" = fit_invgamma_data,
  "Log-normal" = fit_lognormal
)

draws <- lapply(models, FUN = function(model) rstan::extract(model)$l)

df <- do.call("rbind", lapply(
  seq_along(draws),
  FUN = function(i) { data.frame(l = draws[[i]], type = names(draws)[i], mean = mean(draws[[i]]), truth = 2.5) }
))

fig_posterior <- ggplot(df, aes(x = l, fill = type)) +
  geom_histogram(aes(y = ..density..)) +
  geom_vline(aes(xintercept = truth), col = "grey30") +
  facet_wrap(~ type, ncol = 3, scales = "free") +
  scale_fill_manual(values = cbpalette) +
  labs(y = "Posterior density", x = "Lengthscale", fill = "") +
  theme_minimal() +
  coord_cartesian(ylim = c(0, NA), expand = FALSE) +
  guides(fill = "none") +
  theme(panel.grid.major = element_blank())

fig_prior

ggsave("lengthscale-prior.png", h = 3, w = 6.25, bg = "white")

fig_posterior

ggsave("lengthscale-posterior.png", h = 4, w = 6.25, bg = "white")
