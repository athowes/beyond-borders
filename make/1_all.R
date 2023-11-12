source("make/utils.R")

#' 1. Simulate data
run_commit_push("1_draw_vignette-geometries") #' [x]
run_commit_push("1_sim_vignette-geometries")  #' [x]
run_commit_push("1_sim_realistic-geometries") #' [x]

#' 2. Create plots
run_commit_push("1_plot_simulation-geometries") #' [x]

#' 3. Fit models and assess marginals

#' Vignette and realistic together
run_commit_push("1_run", param = list(inf_function = "constant_aghq")) #' [ ]
run_commit_push("1_run", param = list(inf_function = "iid_aghq"))      #' [x]
run_commit_push("1_run", param = list(inf_function = "besag_aghq"))    #' [x]
run_commit_push("1_run", param = list(inf_function = "bym2_aghq"))     #' [ ]
run_commit_push("1_run", param = list(inf_function = "fck_aghq"))      #' [ ]
run_commit_push("1_run", param = list(inf_function = "fik_aghq"))      #' [ ]
run_commit_push("1_run", param = list(inf_function = "ck_aghq"))       #' [ ]
run_commit_push("1_run", param = list(inf_function = "ik_aghq"))       #' [ ]

#' 4. Post-process
run_commit_push("1_process_metric-tables")     #' [ ]
run_commit_push("1_plot_metric-maps")          #' [ ]
run_commit_push("1_plot_metric-boxplots")      #' [ ]
run_commit_push("1_plot_coverage")             #' [ ]
run_commit_push("1_plot_lengthscale-recovery") #' [ ]

#' 5. Checks
run_commit_push("1_checks") #' [ ]
