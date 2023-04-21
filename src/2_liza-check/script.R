#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_liza-check")
# setwd("src/2_liza-check")

survey <- "mwi2016phia"
sf <- st_read(paste0("depends/", survey, ".geojson"))

#' Remove the island of Likoma
sf <- filter(sf, area_name != "Likoma")

#' Error here
#' Error in Ops.units(abs(x), .Machine$integer.max): both operands of the expression should be "units" objects
fit <- arealutils::ck_stan(sf)
