#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("analyze_assessment-results")
# setwd("src/analyze_assessment-results")

#' Placeholder

df_intercept <- readRDS("depends/df_intercept.rds")
df_lengthscale <- readRDS("depends/df_lengthscale.rds")
df_rho <- readRDS("depends/df_rho.rds")
df_time <- readRDS("depends/df_time.rds")

#' #' For IK simulated data, what's the difference between Besag, FCK and FIK over the different geometries?
#' irregularity_effect <- df_rho %>%
#'   filter(sim_model == "IK", inf_model %in% c("Besag", "FCK", "FIK")) %>%
#'   group_by(geometry) %>%
#'   mutate(crps = 1000 * crps_mean,
#'          crps_min = min(crps),
#'          diff = crps - crps_min) %>%
#'   select(inf_model, diff)
#'
#' # FCK versus best (FIK)
#' irregularity_effect %>% filter(inf_model == "FCK") %>% mutate_if(is.numeric, round, 1)
#'
#' # Besag versus best (FIK)
#' irregularity_effect %>% filter(inf_model == "Besag") %>% mutate_if(is.numeric, round, 1)
