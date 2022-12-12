source("make/utils.R")

run_commit_push("2_checks")

#' 1. Pull surveys

#' The four surveys required are:
#' * civ2017phia
#' * mwi2016phia
#' * tza2017phia
#' * zwe2016phia

orderly::orderly_pull_archive("civ_data_survey", remote = "naomi2")            #' [x]
orderly::orderly_pull_archive("mwi_data_survey-indicators", remote = "malawi") #' [x]
orderly::orderly_pull_archive("tza_data_survey", remote = "naomi2")            #' [x]
orderly::orderly_pull_archive("zwe_data_survey", remote = "naomi2")            #' [x]

run_commit_push("2_process_hiv-surveys", push = FALSE) #' [x]

#' Pull the area files too
orderly::orderly_pull_archive("civ_data_areas", remote = "naomi2") #' [x]
orderly::orderly_pull_archive("mwi_data_areas", remote = "naomi2") #' [x]
orderly::orderly_pull_archive("tza_data_areas", remote = "naomi2") #' [x]
orderly::orderly_pull_archive("zwe_data_areas", remote = "naomi2") #' [x]

#' 2. Cross-validate models
run_commit_push("2_cv", param = list(f = "constant_inla"))
run_commit_push("2_cv", param = list(f = "iid_inla"))
run_commit_push("2_cv", param = list(f = "besag_inla"))
run_commit_push("2_cv", param = list(f = "bym2_inla"))
run_commit_push("2_cv", param = list(f = "fck_inla"))
run_commit_push("2_cv", param = list(f = "fik_inla"))
run_commit_push("2_cv", param = list(f = "ck_stan"))
run_commit_push("2_cv", param = list(f = "ik_stan"))

run_commit_push("2_assess_cv") #' [ ]

#' 3. Post-process
run_commit_push("2_process_metric-tables")        #' [ ]
run_commit_push("2_plot_metric-maps")             #' [ ]
run_commit_push("2_plot_prev-ladder")             #' [ ]
run_commit_push("2_process_compare-to-manual-cv") #' [ ] Probably supplementary material
