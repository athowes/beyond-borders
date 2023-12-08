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
    mutate(
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
    ) %>%
    ggplot(aes(x = forcats::fct_rev(inf_model), y = crps, col = inf_model_type)) +
    stat_summary(fun = "mean", geom = "point", position = position_dodge(width = 0.5), size = 2.5) +
    stat_summary(fun.data = mean_se, geom = "errorbar", fun.args = list(mult = 1.96), width = 0.2) +
    geom_jitter(size = 2, width = 0.1, alpha = 0.5, shape = 1) +
    coord_flip() +
    labs(x = "Inferential model", y = "Leave-one-out continuous ranked probability score", col = "", subtitle = subtitle[i]) +
    scale_colour_manual(values = cbpalette) +
    guides(col = guide_legend(override.aes = list(size = 3, alpha = 1, shape = 15, linetype = c(0, 0, 0)))) +
    theme_minimal() +
    theme(
      legend.position = "top",
      legend.justification = "left",
      plot.subtitle = element_text(size = 10, hjust = 1, )
    )

  ggsave(paste0("crps-mean-se-", x, ".png"), h = 5, w = 6.25, bg = "white")
})
