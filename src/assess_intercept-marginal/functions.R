marginal_intercept <- function(fit, ...) {
  UseMethod("marginal_intercept")
}

marginal_intercept.inla <- function(fit, S = 1000) {
  df <- data.frame(fit$marginals.fixed$"(Intercept)")
  samples_list <- INLA::inla.posterior.sample(n = S, fit)
  samples <- sapply(samples_list, function(x) x$latent["(Intercept):1", ])
  summary <- fit$summary.fixed["(Intercept)", ]
  return(list(
    df = df, samples = samples, mean = summary$mean, mode = summary$mode,
    lower = summary$"0.025quant", upper = summary$"0.975quant"
  ))
}

marginal_intercept.inlax <- function(fit, S = 1000) {
  df <- data.frame(fit$marginals.fixed$"(Intercept)")
  samples <- sapply(fit[["samples"]], function(x) x$latent["(Intercept):1", ])
  summary <- fit$summary.fixed["(Intercept)", ]
  return(list(
    df = df, samples = samples, mean = summary$mean, mode = summary$mode,
    lower = summary$"0.025quant", upper = summary$"0.975quant"
  ))
}

marginal_intercept.stanfit <- function(fit, S = 1000) {
  samples <- rstan::extract(fit, pars = "beta_0")$beta_0
  kde <- density(samples)
  df <- data.frame(x = kde$x, y = kde$y)
  summary <- rstan::summary(fit)$summary["beta_0", ]
  return(list(
    df = df, samples = samples, mean = summary[["mean"]], mode = summary[["50%"]],
    lower = summary[["2.5%"]], upper = summary[["97.5%"]]
  ))
}

assess_marginal_intercept <- function(intercept = -2, fit) {
  marginal <- marginal_intercept(fit)
  obs <- intercept
  error_samples <- (marginal$samples - obs)
  f <- approxfun(marginal$df$x, marginal$df$y, yleft = 0, yright = 0)

  return(list(
    obs = obs,
    mean = marginal$mean,
    mode = marginal$mode,
    lower = marginal$lower,
    upper = marginal$upper,
    mse = mean(error_samples^2),
    mae = mean(abs(error_samples)),
    crps = bsae::crps(marginal$samples, obs),
    lds = log(f(obs)),
    quantile = cubature::cubintegrate(f, lower = -Inf, upper = obs, method = "pcubature")$integral
  ))
}
