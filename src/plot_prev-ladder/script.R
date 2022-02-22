#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_prev-ladder")
# setwd("src/plot_prev-ladder")

df <- readRDS("depends/df.rds")

surveys <- c("civ2017phia", "mwi2016phia")
# surveys <- c("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")

pdf("prev-ladder.pdf", h = 6, w = 6.25)

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
    ggplot(aes(x = area_name, by, y = estimate, ymin = ci_lower, ymax = ci_upper, group = inf_model, color = inf_model)) +
    geom_pointrange(position = position_dodge(width = 0.6), alpha = 0.8) +
    labs(x = "District", y = "Posterior prevalence estimate", col = "Inferential model") +
    theme_minimal() +
    scale_color_manual(values = multi.utils::cbpalette()) +
    coord_flip()
})

dev.off()
