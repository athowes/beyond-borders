# orderly::orderly_develop_start("demo_areal-kernels")
# setwd("src/demo_areal-kernels")

#' Run models
source("centroid.R")
source("integrated.R")

#' Create report
rmarkdown::render("areal-kernels.Rmd")
