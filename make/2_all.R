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
run_commit_push("2_cv", param = list(f = "iid_aghq"))      #' [x]
run_commit_push("2_cv", param = list(f = "besag_aghq"))    #' [x]
run_commit_push("2_cv", param = list(f = "bym2_aghq"))     #' [x]
run_commit_push("2_cv", param = list(f = "fck_aghq"))      #' [x]
run_commit_push("2_cv", param = list(f = "fik_aghq"))      #' [x]
run_commit_push("2_cv", param = list(f = "ck_aghq"))       #' [x]
run_commit_push("2_cv", param = list(f = "ik_aghq"))       #' [ ]

#' 3. Fits without left out data
run_commit_push("2_ic", param = list(f = "constant_aghq")) #' [ ]
run_commit_push("2_ic", param = list(f = "iid_aghq"))      #' [x]
run_commit_push("2_ic", param = list(f = "besag_aghq"))    #' [x]
run_commit_push("2_ic", param = list(f = "bym2_aghq"))     #' [x]
run_commit_push("2_ic", param = list(f = "fck_aghq"))      #' [x]
run_commit_push("2_ic", param = list(f = "fik_aghq"))      #' [x]
run_commit_push("2_ic", param = list(f = "ck_aghq"))       #' [x]
run_commit_push("2_ic", param = list(f = "ik_aghq"))       #' [ ]

#' 4. Post-process
run_commit_push("2_plot_mean-se")    #' [x]
run_commit_push("2_plot_maps")       #' [x]
run_commit_push("2_process_tables")  #' [x]
run_commit_push("2_plot_coverage")   #' [x]
run_commit_push("2_plot_ladder")     #' [x]
