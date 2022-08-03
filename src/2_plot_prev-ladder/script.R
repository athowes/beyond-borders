#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_plot_prev-ladder")
# setwd("src/2_plot_prev-ladder")

df <- readRDS("depends/df.rds")
direct <- readRDS("depends/manual.rds")

surveys <- c("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")

pdf("prev-ladder.pdf", h = 8, w = 6.25)

lapply(surveys, function(x) {
  df %>%
    filter(survey_id == toupper(x)) %>%
    mutate(inf_model = recode_factor(inf_model,
      "raw" = "Raw",
      "constant_inla" = "Constant",
      "iid_inla" = "IID",
      "besag_inla" = "Besag",
      "bym2_inla" = "BYM2",
      "fck_inla" = "FCK",
      "ck_stan" = "CK",
      "fik_inla" = "FIK",
      "ik_stan" = "IK")
    ) %>%
    group_by(area_id) %>%
    mutate(average_estimate = mean(estimate)) %>%
    ungroup() %>%
    mutate(area_name = fct_reorder(area_name, average_estimate)) %>%
    ggplot(aes(x = area_name, y = estimate, ymin = ci_lower, ymax = ci_upper, group = inf_model, color = inf_model)) +
    geom_pointrange(position = position_dodge(width = 0.6), alpha = 0.8) +
    labs(x = "", y = "Posterior HIV prevalence estimate", col = "Inferential model") +
    theme_minimal() +
    scale_color_manual(values = multi.utils::cbpalette()) +
    coord_flip() +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      legend.title = element_text(size = 9),
      legend.text = element_text(size = 9)
    )
})

dev.off()

pdf("crps-ladder.pdf", h = 8, w = 6.25)

lapply(surveys, function(x) {
  manual %>%
    filter(survey == x) %>%
    mutate(inf_model = recode_factor(inf_model,
                                     "raw" = "Raw",
                                     "constant_inla" = "Constant",
                                     "iid_inla" = "IID",
                                     "besag_inla" = "Besag",
                                     "bym2_inla" = "BYM2",
                                     "fck_inla" = "FCK",
                                     "ck_stan" = "CK",
                                     "fik_inla" = "FIK",
                                     "ik_stan" = "IK")
    ) %>%
    group_by(id) %>%
    mutate(average_crps = mean(crps)) %>%
    ungroup() %>%
    mutate(id = fct_reorder(as.factor(id), average_crps)) %>%
    ggplot(aes(x = id, y = crps, group = inf_model, color = inf_model)) +
    geom_point(position = position_dodge(width = 0.6), alpha = 0.8) +
    labs(x = "", y = "CRPS", col = "Inferential model") +
    theme_minimal() +
    scale_color_manual(values = multi.utils::cbpalette()) +
    coord_flip() +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      legend.title = element_text(size = 9),
      legend.text = element_text(size = 9)
    )
})

dev.off()
