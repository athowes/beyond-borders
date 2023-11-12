source("make/utils.R")

#' 1. Simulate data
run_commit_push("1_draw_vignette-geometries") #' [x]
run_commit_push("1_sim_vignette-geometries")  #' [x]
run_commit_push("1_sim_realistic-geometries") #' [x]

#' 2. Create plots
run_commit_push("1_plot_simulation-geometries") #' [x]

#' 3. Fit models and assess marginals

#' Vignette and realistic together
id <- orderly::orderly_run("1_fit", param = list(f = "constant_aghq")) #' [ ]
orderly::orderly_commit(id)

id <- orderly::orderly_run("1_fit", param = list(f = "iid_aghq"))      #' [x]
orderly::orderly_commit(id)

id <- orderly::orderly_run("1_fit", param = list(f = "besag_aghq"))    #' [ ]
orderly::orderly_commit(id)

id <- orderly::orderly_run("1_fit", param = list(f = "bym2_aghq"))     #' [ ]
orderly::orderly_commit(id)

id <- orderly::orderly_run("1_fit", param = list(f = "fck_aghq"))      #' [ ]
orderly::orderly_commit(id)

id <- orderly::orderly_run("1_fit", param = list(f = "fik_aghq"))      #' [ ]
orderly::orderly_commit(id)

id <- orderly::orderly_run("1_fit", param = list(f = "ck_aghq"))       #' [ ]
orderly::orderly_commit(id)

id <- orderly::orderly_run("1_fit", param = list(f = "ik_aghq"))       #' [ ]
orderly::orderly_commit(id)

#' 4. Post-process
run_commit_push("1_process_metric-tables")     #' [ ]
run_commit_push("1_plot_metric-maps")          #' [ ]
run_commit_push("1_plot_metric-boxplots")      #' [ ]
run_commit_push("1_plot_coverage")             #' [ ]
run_commit_push("1_plot_lengthscale-recovery") #' [ ]

#' 5. Checks
run_commit_push("1_checks") #' [ ]
