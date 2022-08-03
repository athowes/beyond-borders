#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_process_compare-to-manual-cv")
# setwd("src/2_process_compare-to-manual-cv")

manual <- readRDS("depends/manual.rds")
direct <- readRDS("depends/direct.rds")

#' Need to get CPO in manual CV to compare to direct from R-INLA
manual
direct
