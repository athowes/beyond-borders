# orderly::orderly_develop_start("0_checks")
# setwd("src/0_checks")

rmarkdown::render("bin-gaussian.Rmd")
rmarkdown::render("ik-compute.Rmd")
rmarkdown::render("ik-converge.Rmd")
rmarkdown::render("xbinom.Rmd")
