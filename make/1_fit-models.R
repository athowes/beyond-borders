source("make/utils.R")

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
