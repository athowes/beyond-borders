#' Most models don't have lengthscales
#' The behaviour I'm aiming for is that lengthscale_df eventually just contains rows for the ones that do
#' Perhaps returning NULL is a good way to do this, likely there are better solutions

marginal_lengthscale <- function(fit, ...) {
  UseMethod("marginal_lengthscale")
}

marginal_lengthscale.inla <- function(fit, S = 1000) {
  warning("R-INLA models don't have a length-scale!")
  return(NULL)
}

marginal_lengthscale.inlax <- function(fit, S = 1000) {
  warning("R-INLA models don't have a length-scale!")
  return(NULL)
}

marginal_lengthscale.stanfit <- function(fit, S = 1000) {
  if(!("l" %in% rownames(rstan::summary(fit)$summary))){
    # For other use-cases need more general approach to deal with e.g. rho[1]
    warning("This Stan model doesn't have a length-scale!")
    return(NULL)
  }
  samples <- rstan::extract(fit, pars = "l")$l
  kde <- density(samples)
  df <- data.frame(x = kde$x, y = kde$y)
  summary <- rstan::summary(fit)$summary
  mean <- summary["l", "mean"]
  mode <- summary["l", "50%"]
  lower <- summary["l", "2.5%"]
  upper <- summary["l", "97.5%"]
  return(list(df = df, samples = samples, mean = mean, mode = mode, lower = lower, upper = upper))
}

assess_marginal_lengthscale <- function(lengthscale = 1, fit) {
  marginal <- marginal_lengthscale(fit)

  if(is.null(marginal)){
    return(NULL)
  }

  obs <- lengthscale
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
    quantile = cubature::cubintegrate(f, lower = 0, upper = obs, method = "pcubature")$integral
  ))
}
