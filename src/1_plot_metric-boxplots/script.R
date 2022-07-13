#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_plot_metric-boxplots")
# setwd("src/1_plot_metric-boxplots")

df_rho <- readRDS("depends/df_rho.rds")
df_intercept <- readRDS("depends/df_intercept.rds")

#' CRPS boxplot for rho
pdf("crps-boxplot-rho.pdf", h = 4, w = 6.25)

# df_rho %>%
#   bsae::update_naming() %>%
#   split(.$geometry) %>%
#   lapply(function(x) {
#     boxplot(x, metric = "crps", y_lab = "CRPS")
#   })

df_rho %>%
  filter(inf_model != "constant_inla") %>%
  bsae::update_naming() %>%
  split(.$geometry) %>%
  lapply(function(x) {
    boxplot(x, metric = "crps", y_lab = "CRPS")
  })

dev.off()

#' CRPS boxplot for the intercept
pdf("crps-boxplot-intercept.pdf", h = 7, w = 6.25)

# df_intercept %>%
#   bsae::update_naming() %>%
#   split(.$geometry) %>%
#   lapply(function(x) {
#     boxplot(x, metric = "crps", y_lab = "CRPS")
#   })

df_intercept %>%
  filter(inf_model != "constant_inla") %>%
  bsae::update_naming() %>%
  split(.$geometry) %>%
  lapply(function(x) {
    boxplot(x, metric = "crps", y_lab = "CRPS")
  })

dev.off()
