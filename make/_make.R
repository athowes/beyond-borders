source("make/create-plots")

#' Misc.
source("make/0_all.R")

#' Simulation study
source("make/1_simulate-data.R")
source("make/1_fit-models.R")
source("make/1_assess-marginals.R")
source("make/1_post-process.R")

#' HIV data study
source("make/2_pull-surveys")
source("make/2_cv-models")
