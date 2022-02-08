source("make/utils.R")

run_commit_push("fit_constant-inla")
run_commit_push("fit_iid-inla")
run_commit_push("fit_besag-inla")
run_commit_push("fit_bym2-inla") #' n = 20 took 30 minutes
run_commit_push("fit_fck-inla")
run_commit_push("fit_fik-inla")
# run_commit_push("fit_ck-stan")
# run_commit_push("fit_ik-stan")
