#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_plot_mean-se")
# setwd("src/2_plot_mean-se")

discard_fails <- function(x) {
  lapply(x, function(y) y$result)
}

fct_case_when <- function(...) {
  args <- as.list(match.call())
  levels <- sapply(args[-1], function(f) f[[3]])
  levels <- levels[!is.na(levels)]
  factor(dplyr::case_when(...), levels=levels)
}

df <- bind_rows(
  discard_fails(readRDS("depends/cv_iid.rds")),
  discard_fails(readRDS("depends/cv_besag.rds")),
  discard_fails(readRDS("depends/cv_bym2.rds")),
  discard_fails(readRDS("depends/cv_fck.rds")),
  discard_fails(readRDS("depends/cv_fik.rds")),
  discard_fails(readRDS("depends/cv_ck.rds")),
  discard_fails(readRDS("depends/cv_ik.rds"))
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
    ggplot(aes(x = forcats::fct_rev(inf_model), y = crps, col = inf_model_type, shape = type)) +
    geom_jitter(size = 1.5, width = 0.05, alpha = 0.4) +
    stat_summary(fun = "mean", geom = "point", size = 3, position = position_nudge(x = 0.2, y = 0)) +
    stat_summary(fun.data = mean_se, geom = "errorbar", fun.args = list(mult = 1.96), width = 0.3, position = position_nudge(x = 0.2, y = 0)) +
    coord_flip() +
    facet_grid(type ~ .) +
    labs(x = "Inferential model", y = "Continuous ranked probability score", col = "", subtitle = subtitle[i], shape = "") +
    scale_colour_manual(values = cbpalette) +
    guides(
      col = guide_legend(override.aes = list(size = 3, alpha = 1, shape = 15, linetype = c(0, 0, 0))),
      shape = guide_legend(override.aes = list(col = "grey50"))
    ) +
    theme_minimal() +
    theme(
      legend.position = "top",
      legend.justification = "left",
      plot.subtitle = element_text(size = 10, hjust = 1)
    )

  ggsave(paste0("crps-mean-se-", x, ".png"), h = 6, w = 6.25, bg = "white")
})

df %>%
  mutate(
    survey = recode_factor(survey,
      "civ2017phia" = "Côte d’Ivoire, PHIA 2017",
      "mwi2016phia" = "Malawi, PHIA 2016",
      "tza2017phia" = "Tanzania, PHIA 2017",
      "zwe2016phia" = "Zimbabwe, PHIA 2016"
    ),
    type = as.factor(type)
  ) %>%
  group_by(inf_model, inf_model_type, type, survey) %>%
  summarise(
    mean = mean(crps, na.rm = TRUE),
    se = sd(crps) / n()
  ) %>%
  ggplot(aes(y = forcats::fct_rev(inf_model), x = mean, col = inf_model_type, group = survey, shape = type)) +
  geom_pointrange(aes(xmin = mean - 1.96 * se, xmax = mean + 1.96 * se, group = type),  position = position_dodge2(width = 0.5, reverse = TRUE), size = 0.5) +
  facet_wrap(survey ~ ., scales = "free", ncol = 2) +
  labs(y = "Inferential model", x = "Continuous ranked probability score", col = "", shape = "") +
  scale_colour_manual(values = cbpalette) +
  guides(
    col = guide_legend(override.aes = list(size = 0.6, alpha = 1, shape = 15, linetype = c(0, 0, 0))),
    shape = guide_legend(override.aes = list(col = "grey50", linetype = c(0, 0)))
  ) +
  theme_minimal() +
  theme(
    legend.position = "top",
    legend.justification = "centre"
  )

ggsave("crps-mean-se-surveys.png", h = 6, w = 6.25, bg = "white")
