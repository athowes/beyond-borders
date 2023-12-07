#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_plot_mean-se")
# setwd("src/2_plot_mean-se")

df <- bind_rows(
  readRDS("depends/cv_iid.rds"),
  readRDS("depends/cv_besag.rds")
)

cbpalette <- c("#56B4E9","#009E73", "#E69F00", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

df$result %>%
  filter(survey == "civ2017phia") %>%
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
    )
  ) %>%
  ggplot(aes(x = inf_model, y = crps, col = inf_model)) +
    geom_point(shape = 73, size = 10) +
    coord_flip() +
    labs(x = "Inferential model", y = "Continuous ranked probability score", col = "") +
    scale_colour_manual(values = cbpalette) +
    theme_minimal() +
    theme(
      legend.position = "bottom"
    )

ggsave("temp.png", h = 4, w = 6.25, bg = "white")
