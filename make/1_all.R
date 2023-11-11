source("make/utils.R")

#' 1. Simulate data
run_commit_push("1_draw_vignette-geometries") #' [x]
run_commit_push("1_sim_vignette-geometries")  #' [x]
run_commit_push("1_sim_realistic-geometries") #' [x]

#' 2. Create plots
run_commit_push("1_plot_simulation-geometries") #' [x]

#' 3. Fit models

#' Vignette and realistic together
run_commit_push("1_fit", param = list(f = "constant_aghq")) #' [ ]
run_commit_push("1_fit", param = list(f = "iid_inla"))      #' [ ]
run_commit_push("1_fit", param = list(f = "besag_inla"))    #' [ ]
run_commit_push("1_fit", param = list(f = "bym2_inla"))     #' [ ]
run_commit_push("1_fit", param = list(f = "fck_inla"))      #' [ ]
run_commit_push("1_fit", param = list(f = "fik_inla"))      #' [ ]
run_commit_push("1_fit", param = list(f = "ck_stan"))       #' [ ]
run_commit_push("1_fit", param = list(f = "ik_stan"))       #' [ ]

#' 4. Assess marginals
run_commit_push("1_assess_rho-marginals")        #' [ ]
run_commit_push("1_assess_intercept-marginal")   #' [ ]
run_commit_push("1_assess_lengthscale-marginal") #' [ ]
run_commit_push("1_assess_time-taken")           #' [ ]

#' 5. Post-process
run_commit_push("1_process_metric-tables")     #' [ ]
run_commit_push("1_plot_metric-maps")          #' [ ]
run_commit_push("1_plot_metric-boxplots")      #' [ ]
run_commit_push("1_plot_coverage")             #' [ ]
run_commit_push("1_plot_lengthscale-recovery") #' [ ]

#' 6. Checks
run_commit_push("1_checks") #' [ ]
