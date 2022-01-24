marginal_intercept <- function(fit, ...) {
  UseMethod("marginal_intercept")
}

marginal_intercept.inla <- function(fit, S = 1000) {
  df <- data.frame(fit$marginals.fixed$"(Intercept)")
  samples_list <- INLA::inla.posterior.sample(n = S, fit)
  samples <- sapply(samples_list, function(x) x$latent["(Intercept):1", ])
  mean <- fit$summary.fixed["(Intercept)", ]$mean
  mode <- fit$summary.fixed["(Intercept)", ]$mode
  lower <- fit$summary.fixed["(Intercept)", ]$"0.025quant"
  upper <- fit$summary.fixed["(Intercept)", ]$"0.975quant"
  return(list(df = df, samples = samples, mean = mean, mode = mode, lower = lower, upper = upper))
}

marginal_intercept.stanfit <- function(fit, S = 1000) {
  samples <- rstan::extract(fit, pars = "beta_0")$beta_0
  kde <- density(samples)
  df <- data.frame(x = kde$x, y = kde$y)
  summary <- rstan::summary(fit)$summary
  mean <- summary["beta_0", "mean"]
  mode <- summary["beta_0", "50%"]
  lower <- summary["beta_0", "2.5%"]
  upper <- summary["beta_0", "97.5%"]
  return(list(df = df, samples = samples, mean = mean, mode = mode, lower = lower, upper = upper))
}

assess_marginal_intercept <- function(intercept = -2, fit) {
  marginal <- marginal_intercept(fit)
  obs <- intercept
  error_samples <- (marginal$samples - obs)
  mean <- marginal$mean
  mode <- marginal$mode
  f <- approxfun(marginal$df$x, marginal$df$y, yleft = 0, yright = 0)

  return(list(
    obs = obs,
    mean = mean,
    mode = mode,
    lower = marginal$lower,
    upper = marginal$upper,
    mse = mean(error_samples^2),
    mae = mean(abs(error_samples)),
    mse_mean = (obs - mean)^2,
    mae_mean = abs(obs - mean),
    mse_mode = (obs - mode)^2,
    mae_mode = abs(obs - mode),
    crps = bsae::crps(marginal$samples, obs),
    lds = log(f(obs)),
    quantile = cubature::cubintegrate(f, lower = -Inf, upper = obs, method = "pcubature")$integral
  ))
}
