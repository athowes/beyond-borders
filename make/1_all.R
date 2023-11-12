source("make/utils.R")

#' 1. Simulate data
run_commit_push("1_draw_vignette-geometries") #' [x]
run_commit_push("1_sim_vignette-geometries")  #' [x]
run_commit_push("1_sim_realistic-geometries") #' [x]

#' 2. Create plots
run_commit_push("1_plot_simulation-geometries") #' [x]

#' 3. Fit models and assess marginals

#' Vignette and realistic together
run_commit_push("1_run", param = list(f = "constant_aghq")) #' [ ]
run_commit_push("1_run", param = list(f = "iid_aghq"))      #' [x]
run_commit_push("1_run", param = list(f = "besag_aghq"))    #' [x]
run_commit_push("1_run", param = list(f = "bym2_aghq"))     #' [ ]
run_commit_push("1_run", param = list(f = "fck_aghq"))      #' [ ]
run_commit_push("1_run", param = list(f = "fik_aghq"))      #' [ ]
run_commit_push("1_run", param = list(f = "ck_aghq"))       #' [ ]
run_commit_push("1_run", param = list(f = "ik_aghq"))       #' [ ]

#' 4. Post-process
run_commit_push("1_process_metric-tables")     #' [ ]
run_commit_push("1_plot_metric-maps")          #' [ ]
run_commit_push("1_plot_metric-boxplots")      #' [ ]
run_commit_push("1_plot_coverage")             #' [ ]
run_commit_push("1_plot_lengthscale-recovery") #' [ ]

#' 5. Checks
run_commit_push("1_checks") #' [ ]
