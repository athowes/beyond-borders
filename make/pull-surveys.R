source("make/utils.R")

#' The four surveys required are: GF AGYW countries
#' * MWI2015DHS
#' * ZWE2015DHS
#' * TZA2012AIS
#' * CIV2012DHS

orderly::orderly_pull_archive("mwi_data_survey-indicators", remote = "malawi")
orderly::orderly_pull_archive("zwe_data_survey", remote = "naomi2")
orderly::orderly_pull_archive("tza_data_survey", remote = "naomi2")
orderly::orderly_pull_archive("civ_data_survey", remote = "naomi2")

run_commit_push("process_hiv-surveys", push = FALSE)
