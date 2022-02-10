source("make/utils.R")

#' Vignette
run_commit_push("fit_constant-inla", param = list(realistic = FALSE))
run_commit_push("fit_iid-inla", param = list(realistic = FALSE)
run_commit_push("fit_besag-inla", param = list(realistic = FALSE)
run_commit_push("fit_bym2-inla", param = list(realistic = FALSE)
run_commit_push("fit_fck-inla", param = list(realistic = FALSE)
run_commit_push("fit_fik-inla", param = list(realistic = FALSE)

#' Realistic
run_commit_push("fit_constant-inla", param = list(vignette = FALSE))
run_commit_push("fit_iid-inla", param = list(vignette = FALSE))
run_commit_push("fit_besag-inla", param = list(vignette = FALSE))
run_commit_push("fit_bym2-inla", param = list(vignette = FALSE))
run_commit_push("fit_fck-inla", param = list(vignette = FALSE))
run_commit_push("fit_fik-inla", param = list(vignette = FALSE))
