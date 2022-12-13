# orderly::orderly_develop_start("1_checks")
# setwd("src/1_checks")

rmarkdown::render("inla-mcmc.Rmd")
rmarkdown::render("lengthscale-recovery.Rmd")
