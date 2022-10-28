# orderly::orderly_develop_start("0_explore_hrsl-sampling")
# setwd("src/0_explore_hrsl-sampling")

#' Resources:
#' * https://www.ciesin.columbia.edu/data/hrsl/
#' * https://datacarpentry.org/r-raster-vector-geospatial/
#' * https://gis.stackexchange.com/questions/207119/sampling-random-points-from-large-raster-file-with-replacement-using-r

GDALinfo("hrsl/hrsl_mwi_pop.tif")
mwi_pop <- raster("hrsl/hrsl_mwi_pop.tif")
mwi_pop <- aggregate(mwi_pop, fact = 100)

#' The resolution of the raster layer
res(mwi_pop)

mwi_pop_df <- as.data.frame(mwi_pop, xy = TRUE)

pdf("malawi-hrsl.pdf", h = 5, w = 6.25)

#' It's clearer to see the differences in population density using log transformation
ggplot(data = mwi_pop_df , aes(x = x, y = y, fill = log(hrsl_mwi_pop))) +
  geom_raster(na.rm = TRUE) +
  viridis::scale_fill_viridis(na.value = "white") +
  coord_quickmap() +
  labs(x = "", y = "", fill = "log(Population Density)") +
  theme_minimal()

dev.off()

# proj4string(mw$geometry) <- CRS("+proj=longlat +datum=NAD27")
# proj4string(mwi_pop) <- CRS("+proj=longlat +datum=NAD27")
#
# plot(log(mwi_pop), asp = TRUE)
# plot(mw$geometry, add = TRUE)

#' TODO: How to sample proportionately to population density layer?
