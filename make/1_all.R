source("make/utils.R")

#' 1. Simulate data
run_commit_push("1_sim_geometries") #' [x]

#' 2. Run models and assess
run_commit_push("1_run", param = list(f = "constant_aghq")) #' [ ]
run_commit_push("1_run", param = list(f = "iid_aghq"))      #' [x]
run_commit_push("1_run", param = list(f = "besag_aghq"))    #' [x]
run_commit_push("1_run", param = list(f = "bym2_aghq"))     #' [x]
run_commit_push("1_run", param = list(f = "fck_aghq"))      #' [x]
run_commit_push("1_run", param = list(f = "fik_aghq"))      #' [x]
run_commit_push("1_run", param = list(f = "ck_aghq"))       #' [x]
run_commit_push("1_run", param = list(f = "ik_aghq"))       #' [ ]

#' 4. Post-process
run_commit_push("1_process_tables")    #' [x]
run_commit_push("1_plot_mean-se")      #' [x]
run_commit_push("1_plot_maps")         #' [x]
run_commit_push("1_plot_coverage")     #' [x]
run_commit_push("1_plot_lengthscales") #' [x]
run_commit_push("1_plot_proportions")  #' [x]

#' 5. Checks
run_commit_push("1_check_aghq-nuts") #' [x]
run_commit_push("1_checks")          #' [ ]
