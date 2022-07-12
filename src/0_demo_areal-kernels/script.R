# orderly::orderly_develop_start("0_demo_areal-kernels")
# setwd("src/0_demo_areal-kernels")

#' Run models
source("centroid.R")
source("integrated.R")

#' Create report
rmarkdown::render("areal-kernels.Rmd")
