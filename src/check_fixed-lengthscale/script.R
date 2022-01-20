# orderly::orderly_develop_start("check_fixed-lengthscale")
# setwd("src/check_fixed-lengthscale")

#' Comparing a fixed length-scale model in Stan to R-INLA

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

sf <- mw

l_fixed <- 1
cov <- centroid_covariance(sf, l = l_fixed)

#' Standardised so that the tau prior is right
cov <- cov / riebler_gv(cov)

#' Precision matrix
C <- Matrix::solve(cov)

tau_prior <- list(prec = list(prior = "logtnormal", param = c(0, 1/2.5^2), initial = 0, fixed = FALSE))
beta_prior <- list(mean.intercept = -2, prec.intercept = 1)

fit_inla <- INLA::inla(
  y ~ 1 + f(id, model = "generic0", Cmatrix = C, hyper = tau_prior),
  family = "xbinomial",
  control.family = list(control.link = list(model = "logit")),
  control.fixed = beta_prior,
  data = list(id = 1:nrow(sf), y = sf$y, m = sf$n_obs),
  Ntrials = m,
  control.predictor = list(compute = TRUE, link = 1),
  control.compute = list(dic = TRUE, waic = TRUE, cpo = TRUE, config = TRUE)
)

D <- centroid_distance(sf)

#' check.stan: fixed length-scale

fit_stan <- rstan::stan(
  "fixed-stan/check.stan",
  data = list(n = nrow(sf), y = sf$y, m = sf$n_obs, mu = rep(0, nrow(sf)), D = D, l = l_fixed),
  warmup = 100,
  iter = 4000
)

compare(fit_stan, fit_inla)

#' check-01.stan: fixed length-scale, Gram matrix passed in outright
#' Checking that the Stan code cov_matern32 is correct

fit_inla_01 <- fit_inla

fit_stan_01 <- rstan::stan(
  "fixed-stan/check-01.stan",
  data = list(n = nrow(sf), y = sf$y, m = sf$n_obs, mu = rep(0, nrow(sf)), K = cov),
  warmup = 100,
  iter = 4000
)

compare(fit_stan_01, fit_inla_01)

#' check-02.stan: converting to integers to remove xbinomial

fit_inla_02 <- INLA::inla(
  y ~ 1 + f(id, model = "generic0", Cmatrix = C, hyper = tau_prior),
  family = "binomial",
  control.family = list(control.link = list(model = "logit")),
  control.fixed = beta_prior,
  data = list(id = 1:nrow(sf), y = floor(sf$y), m = floor(sf$n_obs)),
  Ntrials = m,
  control.predictor = list(compute = TRUE, link = 1),
  control.compute = list(dic = TRUE, waic = TRUE, cpo = TRUE, config = TRUE)
)

fit_stan_02 <- rstan::stan(
  "fixed-stan/check-02.stan",
  data = list(n = nrow(sf), y = floor(sf$y), m = floor(sf$n_obs), mu = rep(0, nrow(sf)), K = cov),
  warmup = 100,
  iter = 4000
)

compare(fit_stan_02, fit_inla_02)

#' Does more samples change things?

fit_stan_02_bigger <- rstan::stan(
  "fixed-stan/check-02.stan",
  data = list(n = nrow(sf), y = floor(sf$y), m = floor(sf$n_obs), mu = rep(0, nrow(sf)), K = cov),
  warmup = 100,
  iter = 10000
)

compare(fit_stan_03, fit_inla_03)
