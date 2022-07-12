# orderly::orderly_develop_start("check_inla-mcmc")
# setwd("src/check_inla-mcmc")

#' Checking that R-INLA and Stan produce similar results
#' Would using Stan (slower) for the models below rather than R-INLA (faster) change anything?

#' Example data, should repeat this for others
data <- readRDS("depends/data_iid_grid.rds")
sf <- data[[1]]$sf

#' Constant
fit_inla <- constant_inla(sf)
fit_stan <- constant_stan(sf)
get_time(fit_inla); get_time(fit_stan)

pdf("inla-mcmc-constant.pdf", h = 5, w = 5)

plot(marginal_intervals(fit_inla)$mean, marginal_intervals(fit_stan, parameter = "rho")$mean)

dev.off()

#' IID
fit_inla <- iid_inla(sf)
fit_stan <- iid_stan(sf)
get_time(fit_inla); get_time(fit_stan)

pdf("inla-mcmc-iid.pdf", h = 5, w = 5)

plot(marginal_intervals(fit_inla)$mean, marginal_intervals(fit_stan, parameter = "rho")$mean)

dev.off()

#' Besag
fit_inla <- besag_inla(sf)
fit_stan <- besag_stan(sf)
get_time(fit_inla); get_time(fit_stan)

pdf("inla-mcmc-besag.pdf", h = 5, w = 5)

plot(marginal_intervals(fit_inla)$mean, marginal_intervals(fit_stan, parameter = "rho")$mean)

dev.off()

#' BYM2
fit_inla <- bym2_inla(sf)
fit_stan <- bym2_stan(sf)
get_time(fit_inla); get_time(fit_stan)

pdf("inla-mcmc-bym2.pdf", h = 5, w = 5)

plot(marginal_intervals(fit_inla)$mean, marginal_intervals(fit_stan, parameter = "rho")$mean)

dev.off()

#' TODO: These plots could be improved, ggplot2, a line through x = y
#' Could also check how things look for more than one dataset

