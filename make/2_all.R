source("make/utils.R")

run_commit_push("2_checks") #' [ ]

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
orderly::orderly_pull_archive("civ_data_areas", remote = "naomi2")             #' [x]
orderly::orderly_pull_archive("mwi_data_areas", remote = "naomi2")             #' [x]
orderly::orderly_pull_archive("tza_data_areas", remote = "naomi2")             #' [x]
orderly::orderly_pull_archive("zwe_data_areas", remote = "naomi2")             #' [x]

run_commit_push("2_process_surveys", push = FALSE) #' [x]

#' 2. Cross-validate models
run_commit_push("2_cv", param = list(f = "constant_aghq")) #' [ ]
run_commit_push("2_cv", param = list(f = "iid_aghq"))      #' [ ]
run_commit_push("2_cv", param = list(f = "besag_aghq"))    #' [ ]
run_commit_push("2_cv", param = list(f = "bym2_aghq"))     #' [ ]
run_commit_push("2_cv", param = list(f = "fck_aghq"))      #' [ ]
run_commit_push("2_cv", param = list(f = "fik_aghq"))      #' [ ]
run_commit_push("2_cv", param = list(f = "ck_aghq"))       #' [ ]
run_commit_push("2_cv", param = list(f = "ik_aghq"))       #' [ ]

#' 3. Post-process
run_commit_push("2_process_tables") #' [ ]
run_commit_push("2_plot_maps")      #' [ ]
run_commit_push("2_plot_ladder")    #' [ ]
