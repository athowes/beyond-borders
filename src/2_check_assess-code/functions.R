#' R-INLA $marginals don't cover enough of the space and vulnerable to -Inf?
#' Use KDE on samples here? How does inla.posterior.sample work? Make $marginals higher resolution?
#' https://groups.google.com/g/r-inla-discussion-group/c/7uBoKYkHecg
#' Instance of broader challenge with using log scores e.g.
#' "While the log score requires fairly stringent conditions, the CRPS yields consistent approximations under minimal assumptions
#' Kruger, Lerch, Thorarinsdottir, Gneiting https://arxiv.org/pdf/1608.06802v1.pdf
#' Best probably to avoid (my take) and stick to CRPS

ith_marginal_rho <- function(fit, ...) {
  UseMethod("ith_marginal_rho")
}

ith_marginal_rho.inla <- function(fit, i, S = 4000) {
  df <- data.frame(fit$marginals.fitted.values[[i]])
  samples_list <- INLA::inla.posterior.sample(n = S, fit, selection = list(Predictor = i))
  eta_samples <- sapply(samples_list, function(x) x$latent)
  samples <- plogis(eta_samples)
  mean <- fit$summary.fitted.values[i, ]$mean
  mode <- fit$summary.fitted.values[i, ]$mode
  lower <- fit$summary.fitted.values[i, ]$"0.025quant"
  upper <- fit$summary.fitted.values[i, ]$"0.975quant"
  return(list(df = df, samples = samples, mean = mean, mode = mode, lower = lower, upper = upper))
}

ith_marginal_rho.stanfit <- function(fit, i, S = 4000){
  samples <- rstan::extract(fit, pars = "rho")$rho[, i]
  kde <- density(samples, bw = 0.1, n = 512, from = 0, to = 1)
  df <- data.frame(x = kde$x, y = kde$y)
  summary <- rstan::summary(fit)$summary
  mean <- summary[paste0("rho[", i, "]"), "mean"]
  mode <- summary[paste0("rho[", i, "]"), "50%"]
  lower <- summary[paste0("rho[", i, "]"), "2.5%"]
  upper <- summary[paste0("rho[", i, "]"), "97.5%"]
  return(list(df = df, samples = samples, mean = mean, mode = mode, lower = lower, upper = upper))
}

assess_ith_marginal_rho <- function(rho, fit, i) {
  marginal <- ith_marginal_rho(fit, i)
  obs <- rho[[i]]
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
    crps = arealutils::crps(marginal$samples, obs),
    lds = log(f(obs)),
    quantile = cubature::cubintegrate(f, lower = 0, upper = obs, method = "pcubature")$integral
  ))
}

assess_marginals_rho <- function(rho, fit) {
  res <- sapply(1:length(rho), function(i) assess_ith_marginal_rho(rho, fit, i))
  df <- tidyr::unnest(data.frame(t(res)), cols = mse:quantile) #' Don't want vector of lists
  cbind(id = 1:nrow(df), df)
}
