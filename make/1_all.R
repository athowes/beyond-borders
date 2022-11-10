source("make/utils.R")

#' 1. Simulate data
run_commit_push("1_draw_vignette-geometries") #' [x]
run_commit_push("1_sim_vignette-geometries")  #' [x]
run_commit_push("1_sim_realistic-geometries") #' [x]
run_commit_push("1_plot_simulated-data")      #' [ ]

#' 2. Create plots
run_commit_push("1_plot_simulation-geometries") #' [x]

#' Fit models

#' Vignette and realistic together
run_commit_push("1_fit_constant-inla") #' [x]
run_commit_push("1_fit_iid-inla")      #' [x]
run_commit_push("1_fit_besag-inla")    #' [x]
run_commit_push("1_fit_bym2-inla")     #' [/]
run_commit_push("1_fit_fck-inla")      #' [x]
run_commit_push("1_fit_fik-inla")      #' [x]
run_commit_push("1_fit_ck-stan")       #' [ ]
run_commit_push("1_fit_ik-stan")       #' [ ]

#' #' Vignette alone
#' run_commit_push("1_fit_constant-inla", param = list(realistic = FALSE))
#' run_commit_push("1_fit_iid-inla", param = list(realistic = FALSE))
#' run_commit_push("1_fit_besag-inla", param = list(realistic = FALSE))
#' run_commit_push("1_fit_bym2-inla", param = list(realistic = FALSE))
#' run_commit_push("1_fit_fck-inla", param = list(realistic = FALSE))
#' run_commit_push("1_fit_fik-inla", param = list(realistic = FALSE))
#'
#' #' Realistic alone
#' run_commit_push("1_fit_constant-inla", param = list(vignette = FALSE))
#' run_commit_push("1_fit_iid-inla", param = list(vignette = FALSE))
#' run_commit_push("1_fit_besag-inla", param = list(vignette = FALSE))
#' run_commit_push("1_fit_bym2-inla", param = list(vignette = FALSE))
#' run_commit_push("1_fit_fck-inla", param = list(vignette = FALSE))
#' run_commit_push("1_fit_fik-inla", param = list(vignette = FALSE))

#' 3. Assess marginals
run_commit_push("1_assess_rho-marginals")        #' [x]
run_commit_push("1_assess_intercept-marginal")   #' [x]
run_commit_push("1_assess_lengthscale-marginal") #' [ ]
run_commit_push("1_assess_time-taken")           #' [/]

#' 4. Post-process
run_commit_push("1_process_metric-tables")     #' [x]
run_commit_push("1_plot_metric-maps")          #' [x]
run_commit_push("1_plot_metric-boxplots")      #' [x]
run_commit_push("1_plot_coverage")             #' [x]
run_commit_push("1_plot_lengthscale-recovery") #' [ ]
