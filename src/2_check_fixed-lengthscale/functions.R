compare <- function(fit_stan, fit_inla) {
  summary_stan <- rstan::summary(fit_stan)$summary

  message("INLA's intercept:")
  print(fit_inla$summary.fixed)

  message("Stan's intercept:")
  print(summary_stan["beta_0", ])

  message("INLA's precision:")
  print(fit_inla$summary.hyperpar)

  message("Stan's precision:")
  print(summary_stan["tau_phi", ])

  par(mfrow = c(2, 1))
  plot(fit_inla$summary.random$id[, "mean"], summary_stan[2:(1 + 28), "mean"])
  abline(a = 0, b = 1 / summary_stan["sigma_phi", "mean"])

  plot(fit_inla$summary.fitted.values[, "mean"], summary_stan[60:(59 + 28), "mean"])
  abline(a = 0, b = 1)
}
