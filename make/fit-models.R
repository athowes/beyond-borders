source("make/utils.R")

#' Vignette and realistic together
run_commit_push("fit_constant-inla")
run_commit_push("fit_iid-inla")
run_commit_push("fit_besag-inla")
run_commit_push("fit_bym2-inla")
run_commit_push("fit_fck-inla")
run_commit_push("fit_fik-inla")
run_commit_push("fit_ck-stan")
# run_commit_push("fit_ik-stan")

#' #' Vignette
#' run_commit_push("fit_constant-inla", param = list(realistic = FALSE))
#' run_commit_push("fit_iid-inla", param = list(realistic = FALSE))
#' run_commit_push("fit_besag-inla", param = list(realistic = FALSE))
#' run_commit_push("fit_bym2-inla", param = list(realistic = FALSE))
#' run_commit_push("fit_fck-inla", param = list(realistic = FALSE))
#' run_commit_push("fit_fik-inla", param = list(realistic = FALSE))
#'
#' #' Realistic
#' run_commit_push("fit_constant-inla", param = list(vignette = FALSE))
#' run_commit_push("fit_iid-inla", param = list(vignette = FALSE))
#' run_commit_push("fit_besag-inla", param = list(vignette = FALSE))
#' run_commit_push("fit_bym2-inla", param = list(vignette = FALSE))
#' run_commit_push("fit_fck-inla", param = list(vignette = FALSE))
#' run_commit_push("fit_fik-inla", param = list(vignette = FALSE))
