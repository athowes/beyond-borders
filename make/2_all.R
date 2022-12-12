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
run_commit_push("2_cv_constant-inla") #' [x]
run_commit_push("2_cv_iid-inla")      #' [x]
run_commit_push("2_cv_besag-inla")    #' [x]
run_commit_push("2_cv_bym2-inla")     #' [x]
run_commit_push("2_cv_fck-inla")      #' [/] See issue 35
run_commit_push("2_cv_fik-inla")      #' [/] See issue 36
run_commit_push("2_cv_ck-stan")       #' []
run_commit_push("2_cv_ik-stan")       #' []

run_commit_push("2_assess_cv") #' [x]

#' 3. Post-process
run_commit_push("2_process_metric-tables")        #' [x]
run_commit_push("2_plot_metric-maps")             #' [x]
run_commit_push("2_plot_prev-ladder")             #' [x]
run_commit_push("2_process_compare-to-manual-cv") #' [ ] Probably supplementary material
