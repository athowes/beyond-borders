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
  summary <- rstan::summary(fit)$summary["l", ]
  return(list(
    df = df, samples = samples, mean = summary[["mean"]], mode = summary[["50%"]],
    lower = summary[["2.5%"]], upper = summary[["97.5%"]]
  ))
}

assess_marginal_lengthscale <- function(lengthscale = 5/2, fit) {
  marginal <- marginal_lengthscale(fit)

  if(is.null(marginal)){
    return(NULL)
  }

  obs <- lengthscale
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
    quantile = cubature::cubintegrate(f, lower = 0, upper = obs, method = "pcubature")$integral
  ))
}
