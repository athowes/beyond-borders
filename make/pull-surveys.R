source("make/utils.R")

#' The four surveys required are:
#' * CIV2012DHS
#' * MWI2015DHS
#' * TZA2012AIS
#' * ZWE2015DHS

orderly::orderly_pull_archive("civ_data_survey", remote = "naomi2")
orderly::orderly_pull_archive("mwi_data_survey-indicators", remote = "malawi")
orderly::orderly_pull_archive("tza_data_survey", remote = "naomi2")
orderly::orderly_pull_archive("zwe_data_survey", remote = "naomi2")

run_commit_push("process_hiv-surveys", push = FALSE)

#' Pull the area files too
orderly::orderly_pull_archive("civ_data_areas", remote = "naomi2")
orderly::orderly_pull_archive("mwi_data_areas", remote = "naomi2")
orderly::orderly_pull_archive("tza_data_areas", remote = "naomi2")
orderly::orderly_pull_archive("zwe_data_areas", remote = "naomi2")
