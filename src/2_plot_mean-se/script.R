#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_plot_mean-se")
# setwd("src/2_plot_mean-se")

discard_fails <- function(x) {
  lapply(x, function(y) y$result)
}

df <- bind_rows(
  discard_fails(readRDS("depends/cv_iid.rds")),
  discard_fails(readRDS("depends/cv_besag.rds")),
  discard_fails(readRDS("depends/cv_bym2.rds")),
  discard_fails(readRDS("depends/cv_fck.rds")),
  discard_fails(readRDS("depends/cv_fik.rds")),
  discard_fails(readRDS("depends/cv_ck.rds"))
) %>%
  mutate(
    type = toupper(type),
    inf_model = recode_factor(
      inf_model,
      "constant_aghq" = "Constant",
      "iid_aghq" = "IID",
      "besag_aghq" = "Besag",
      "bym2_aghq" = "BYM2",
      "fck_aghq" = "FCK",
      "ck_aghq" = "CK",
      "fik_aghq" = "FIK",
      "ik_aghq" = "IK"
    ),
    inf_model_type = fct_case_when(
      inf_model == "IID" ~ "Unstructured",
      inf_model %in% c("Besag", "BYM2") ~ "Adjacency",
      inf_model %in% c("FCK", "FIK", "CK", "IK") ~ "Kernel"
    )
  )

cbpalette <- c("#56B4E9","#009E73", "#E69F00", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

fct_case_when <- function(...) {
  args <- as.list(match.call())
  levels <- sapply(args[-1], function(f) f[[3]])
  levels <- levels[!is.na(levels)]
  factor(dplyr::case_when(...), levels=levels)
}

survey_names <- unique(df$survey)

subtitle <- c(
  "Côte d’Ivoire, PHIA 2017",
  "Malawi, PHIA 2016",
  "Tanzania, PHIA 2017",
  "Zimbabwe, PHIA 2016"
)

lapply(seq_along(survey_names), function(i) {
  x <- survey_names[i]

  df %>%
    filter(survey == x) %>%
    ggplot(aes(x = forcats::fct_rev(inf_model), y = crps, col = inf_model_type)) +
    geom_jitter(size = 1.5, width = 0.05, alpha = 0.8, shape = 1, col = "grey75") +
    stat_summary(fun = "mean", geom = "point", position = position_dodge(width = 0.5), size = 3) +
    stat_summary(fun.data = mean_se, geom = "errorbar", fun.args = list(mult = 1.96), width = 0.3) +
    coord_flip() +
    facet_grid(type ~ .) +
    labs(x = "Inferential model", y = "Continuous ranked probability score", col = "", subtitle = subtitle[i]) +
    scale_colour_manual(values = cbpalette) +
    guides(col = guide_legend(override.aes = list(size = 3, alpha = 1, shape = 15, linetype = c(0, 0, 0)))) +
    theme_minimal() +
    theme(
      legend.position = "top",
      legend.justification = "left",
      plot.subtitle = element_text(size = 10, hjust = 1)
    )

  ggsave(paste0("crps-mean-se-", x, ".png"), h = 6, w = 6.25, bg = "white")
})

df %>%
  filter(type == "LOO") %>%
  mutate(
    survey = recode_factor(survey,
      "civ2017phia" = "Côte d’Ivoire\nPHIA 2017",
      "mwi2016phia" = "Malawi\nPHIA 2016",
      "tza2017phia" = "Tanzania\nPHIA 2017",
      "zwe2016phia" = "Zimbabwe\nPHIA 2016"
    )
  ) %>%
  group_by(inf_model, inf_model_type, survey) %>%
  summarise(
    mean = mean(crps, na.rm = TRUE),
    se = sd(crps) / n()
  ) %>%
  ggplot(aes(x = forcats::fct_rev(inf_model), y = mean, col = inf_model_type, group = survey)) +
  geom_pointrange(aes(ymin = mean - 1.96 * se, ymax = mean + 1.96 * se), size = 0.3) +
  facet_grid(survey ~ .) +
  coord_flip() +
  labs(x = "Inferential model", y = "Leave-one-out continuous ranked probability score", col = "") +
  scale_colour_manual(values = cbpalette) +
  guides(col = guide_legend(override.aes = list(size = 0.6, alpha = 1, shape = 15, linetype = c(0, 0, 0)))) +
  theme_minimal() +
  theme(
    legend.position = "top",
    legend.justification = "left"
  )

ggsave("crps-mean-se-surveys.png", h = 5, w = 6.25, bg = "white")
