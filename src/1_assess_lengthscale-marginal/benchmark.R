#' Testing
fits <- readRDS("depends/fits_icar_1_ck_stan.rds")

#' Just the first one
fit <- fits[[1]]

#' The lengthscale marginal
marginal_lengthscale(fit)

#' And its assessment
assess_marginal_lengthscale(lengthscale = 5/2, fit)
