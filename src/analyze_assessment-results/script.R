#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("analyze_assessment-results")
# setwd("src/analyze_assessment-results")

#' Analysis of lengthscale recovery

#' Values of the length-scale recovered by the best_average() function, without any data
calc_best_average <- function(file) {
  readRDS(paste0("depends/", file)) %>%
    centroid_distance() %>%
    bsae::best_average()
}

l_grid <- calc_best_average("grid.rds")
l_ci <- calc_best_average("civ.rds")
l_tex <- calc_best_average("tex.rds")
l_1 <- calc_best_average("geometry-1.rds")
l_2 <- calc_best_average("geometry-2.rds")
l_3 <- calc_best_average("geometry-3.rds")
l_4 <- calc_best_average("geometry-4.rds")
