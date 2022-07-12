source("make/utils.R")

run_commit_push("2_cv_constant-inla") #' [x]
run_commit_push("2_cv_iid-inla") #' [x]
run_commit_push("2_cv_besag-inla") #' [x]
run_commit_push("2_cv_bym2-inla") #' [x]
run_commit_push("2_cv_fck-inla") #' [/] See issue 35
run_commit_push("2_cv_fik-inla") #' [/] See issue 36
run_commit_push("2_cv_ck-stan") #' []
run_commit_push("2_cv_ik-stan") #' []

run_commit_push("2_assess_cv") #' [x]
