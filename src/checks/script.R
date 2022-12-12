# orderly::orderly_develop_start("checks")
# setwd("src/checks")

rmarkdown::render("bin-gaussian.Rmd")
rmarkdown::render("ik-compute.Rmd")
rmarkdown::render("ik-converge.Rmd")
