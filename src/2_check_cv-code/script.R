#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("check_cv-code")
# setwd("src/check_cv-code")

#' Test of cross-validation approach using missing data in Stan

loo_test_sets <- create_folds(mw, type = "LOO")
sloo_test_sets <- create_folds(mw, type = "SLOO")

#' What do the test sets look like?

pdf("loo-sloo-test-sets.pdf", h = 12, w = 6.25)

cowplot::plot_grid(
  plotlist = lapply(loo_test_sets, function(x) {
    x$data %>%
      ggplot(aes(fill = y)) +
        geom_sf() +
        theme_void() +
        theme(
          legend.position = "none"
        )
  }),
  ncol = 7
)

cowplot::plot_grid(
  plotlist = lapply(sloo_test_sets, function(x) {
    x$data %>%
      ggplot(aes(fill = y)) +
      geom_sf() +
      theme_void() +
      theme(
        legend.position = "none"
      )
  }),
  ncol = 7
)

dev.off()

#' Try fitting one of them in Stan
sf <- loo_test_sets[[1]]$data

#' Index of observations which are not missing
ii_obs <- which(!is.na(sf$y))

#' Index of missing observations
ii_mis <- which(is.na(sf$y))

#' Number of not missing observations
n_obs <- length(ii_obs)

#' Number of missing observations
n_mis <- length(ii_mis)

dat <- list(
  n_obs = n_obs,
  n_mis = n_mis,
  ii_obs = array(ii_obs),
  ii_mis = array(ii_mis),
  n = nrow(sf),
  y_obs = sf$y[ii_obs],
  m = sf$n_obs
)

temp <- rstan::stan(file = "constant.stan", data = dat, warmup = 100, iter = 900)
rstan::summary(temp)$summary
out <- rstan::extract(temp)

pdf("y-mis-preds.pdf", h = 4, w = 6.25)

#' Could add truth to this plot and remake in ggplot2
plot(out$y_mis)

dev.off()
