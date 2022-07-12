source("make/utils.R")

#' The four surveys required are:
#' * civ2017phia
#' * mwi2016phia
#' * tza2017phia
#' * zwe2016phia

orderly::orderly_pull_archive("civ_data_survey", remote = "naomi2") #' [x]
orderly::orderly_pull_archive("mwi_data_survey-indicators", remote = "malawi") #' [x]
orderly::orderly_pull_archive("tza_data_survey", remote = "naomi2") #' [x]
orderly::orderly_pull_archive("zwe_data_survey", remote = "naomi2") #' [x]

run_commit_push("2_process_hiv-surveys", push = FALSE) #' [x]

#' Pull the area files too
orderly::orderly_pull_archive("civ_data_areas", remote = "naomi2") #' [x]
orderly::orderly_pull_archive("mwi_data_areas", remote = "naomi2") #' [x]
orderly::orderly_pull_archive("tza_data_areas", remote = "naomi2") #' [x]
orderly::orderly_pull_archive("zwe_data_areas", remote = "naomi2") #' [x]
