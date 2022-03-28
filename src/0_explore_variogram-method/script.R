# orderly::orderly_develop_start("explore_variogram-method")
# setwd("src/explore_variogram-method")

#' Development of variogram methods
#' Aim to automatically determine length-scale

cent_mw <- sf::st_centroid(mw)

#' Size of point corresponds to estimate

pdf("bubble-plot.pdf", h = 7, w = 6.25)

ggplot(mw) +
  geom_sf(fill = "lightgrey") +
  geom_sf(data = cent_mw, aes(size = est)) +
  labs(x = "Longitude", y = "Latitude", fill = "Estimate") +
  theme_minimal() +
  labs(fill = "") +
  theme_minimal()

dev.off()

vario <- variogram(est ~ 1, cent_mw)

pdf("variogram.pdf", h = 4, w = 6.25)

plot(vario)

dev.off()

#' * np: the number of point pairs for this estimate
#' * dist: the average distance of all point pairs considered for this estimate
#' * gamma: the actual sample variogram estimate

fit <- fit.variogram(
  vario,
  model = vgm(
    psill = 1,
    model = "Mat",
    range = 300,
    kappa = 1.5
  )
)

#' * psill: (partial) sill of the variogram model component
#' * model: model type, e.g. "Exp", "Sph", "Gau", "Mat"
#' * range: range parameter of the variogram model component; in case of anisotropy: major range
#' * kappa: smoothness parameter for the Matern class of variogram models
