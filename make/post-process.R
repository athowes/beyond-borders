source("make/utils.R")

#' Simulation study
run_commit_push("process_metric-tables")
run_commit_push("plot_metric-maps")
run_commit_push("plot_metric-boxplots")
run_commit_push("plot_coverage")
run_commit_push("plot_lengthscale-recovery")

#' HIV study
run_commit_push("process_hiv-metric-tables")
run_commit_push("plot_hiv-metric-maps")
run_commit_push("process_compare-to-manual-cv") #' Probably supplementary material
