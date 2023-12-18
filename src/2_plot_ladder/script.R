#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_plot_ladder")
# setwd("src/2_plot_ladder")

ic <- list(
  "iid" = readRDS("depends/ic_iid.rds"),
  "besag" = readRDS("depends/ic_besag.rds"),
  "bym2" = readRDS("depends/ic_bym2.rds"),
  "fck" = readRDS("depends/ic_fck.rds"),
  "fik" = readRDS("depends/ic_fik.rds"),
  "ck" = readRDS("depends/ic_ck.rds"),
  "ik" = readRDS("depends/ic_ik.rds")
)

ic_df <- ic %>%
  flatten() %>%
  keep(~!is.null(.x$result)) %>%
  bind_rows()

ic_df <- ic_df$result  %>%
  mutate(
    inf_model = recode_factor(inf_model,
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
      inf_model %in% c("FCK", "FIK") ~ "Kernel (fixed)",
      inf_model %in% c("CK", "IK") ~ "Kernel (learnt)"
    )
  )

unique_surveys <- unique(ic_df$survey_id)

subtitle <- c(
  "Côte d’Ivoire, PHIA 2017",
  "Malawi, PHIA 2016",
  "Tanzania, PHIA 2017",
  "Zimbabwe, PHIA 2016"
)

cbpalette <- c("#999999", "#56B4E9","#009E73", "#E69F00", "#CC79A7")

lapply(seq_along(unique_surveys), function(i) {
  df <- ic_df %>%
    filter(survey_id == unique_surveys[i])

  # sf <- read_sf(paste0("depends/", tolower(substr(df$survey[1], 1, 3)), "_areas.geojson"))

  df_direct <- df %>%
    filter(inf_model == "IID") %>%
    mutate(
      direct = y / n_obs,
      inf_model = "Direct",
      inf_model_type = "Direct"
    )

  n_method_types <- length(unique(df$inf_model_type))

  ggplot(df_direct) +
    geom_point(aes(x = forcats::fct_reorder(area_name, direct), y = direct, col = inf_model_type), size = 3, shape = 15) +
    geom_pointrange(data = df, aes(x = area_name, y = mean, ymin = lower, ymax = upper, col = inf_model_type), shape = 19) +
    facet_wrap(factor(inf_model, levels = c("Direct", "IID", "Besag", "BYM2", "FCK", "CK", "FIK", "IK")) ~ ., ncol = 2) +
    coord_cartesian(clip = "off") +
    scale_y_continuous(labels = scales::percent, limits = c(0, NA)) +
    scale_colour_manual(values = cbpalette, breaks = c("Direct", "Unstructured", "Adjacency", "Kernel (fixed)", "Kernel (learnt)")) +
    labs(x = "Area (ordered by direct prevalence)", y = "Prevalence estimate", col = "", subtitle = subtitle[i]) +
    guides(col = guide_legend(override.aes = list(shape = c(15, rep(16, n_method_types)), linetype = rep(0, n_method_types + 1)))) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank()
    )

  ggsave(paste0("ladder-", tolower(df$survey_id[1]), ".png"), h = 7.5, w = 6.25, bg = "white")
})
