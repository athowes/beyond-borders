#' Testing
fits <- readRDS("depends/fits_icar_1_besag_inla.rds")
data <- readRDS("depends/data_icar_1.rds")

#' Just the first one
fit <- fits[[1]]
rho <- data_icar_1[[1]][["rho"]]

#' The first marginal
ith_marginal_rho(fit, 1)

#' Its assessment
assess_ith_marginal_rho(rho, fit, 1)

#' Assessment of all of the marginals
assess_marginals_rho(rho, fit)
