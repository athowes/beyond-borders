#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_plot_ladder")
# setwd("src/2_plot_ladder")

ic <- list(
  "iid" = readRDS("depends/ic_iid.rds"),
  "besag" = readRDS("depends/ic_besag.rds")
)

cbpalette <- c("#999999", "#56B4E9","#009E73", "#E69F00", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

lapply(1:4, function(i) {
  df <- purrr::map_df(ic, i) %>%
    mutate(inf_model = recode_factor(
      inf_model,
      "constant_aghq" = "Constant",
      "iid_aghq" = "IID",
      "besag_aghq" = "Besag",
      "bym2_aghq" = "BYM2",
      "fck_aghq" = "FCK",
      "ck_aghq" = "CK",
      "fik_aghq" = "FIK",
      "ik_aghq" = "IK"
    ))

  df_direct <- df %>%
    filter(inf_model == "IID") %>%
    mutate(
      direct = y / n_obs,
      inf_model = "Direct"
    )

  ggplot(df, aes(x = forcats::fct_reorder(area_name, mean), y = mean, ymin = lower, ymax = upper, col = inf_model)) +
    geom_pointrange(position = position_dodge(width = 0.6), alpha = 0.8) +
    geom_point(
      data = df_direct,
      aes(x = area_name, y = direct, col = inf_model), size = 3, shape = 15, alpha = 0.8
    ) +
    coord_flip() +
    scale_y_continuous(labels = scales::percent) +
    scale_colour_manual(values = cbpalette, breaks = c("Direct", "IID", "Besag")) +
    labs(x = "Area name", y = "Prevalence estimate", col = "Inferential model") +
    guides(col = guide_legend(override.aes = list(shape = c(15, rep(16, 2)), linetype = c(0, 0, 0)))) +
    theme_minimal() +
    theme(
      legend.position = "bottom"
    )

  ggsave(paste0("ladder-", tolower(df$survey_id[1]), ".png"), h = 8.5, w = 6.25, bg = "white")
})

