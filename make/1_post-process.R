source("make/utils.R")

run_commit_push("1_process_metric-tables")
run_commit_push("1_plot_metric-maps") #' [x]
run_commit_push("1_plot_metric-boxplots") #' [x]
run_commit_push("1_plot_coverage")
run_commit_push("1_plot_lengthscale-recovery")
