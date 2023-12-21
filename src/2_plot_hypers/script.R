#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_plot_hypers")
# setwd("src/2_plot_hypers")

ic <- list(
  "iid" = readRDS("depends/ic_iid.rds"),
  "besag" = readRDS("depends/ic_besag.rds"),
  "bym2" = readRDS("depends/ic_bym2.rds"),
  "fck" = readRDS("depends/ic_fck.rds"),
  "fik" = readRDS("depends/ic_fik.rds"),
  "ck" = readRDS("depends/ic_ck.rds"),
  "ik" = readRDS("depends/ic_ik.rds")
)

key_df <- ic %>%
  flatten() %>%
  keep(~!is.null(.x$result)) %>%
  map("result") %>%
  map("df") %>%
  bind_rows(.id = "id") %>%
  select(id, survey_id, inf_model) %>%
  st_drop_geometry() %>%
  distinct()

ic_fit <- ic %>%
  flatten() %>%
  keep(~!is.null(.x$result)) %>%
  map("result") %>%
  map("fit")

#' BYM2 proportion parameter
bym2_index <- key_df %>%
  filter(inf_model == "bym2_aghq") %>%
  pull(id) %>%
  as.numeric()

phi_samples <- lapply(bym2_index, function(i) {
  fit <- ic_fit[[i]]
  samples <- aghq::sample_marginal(fit, M = 1000)
  theta_samples <- data.frame(do.call(cbind, samples$thetasamples))
  names(theta_samples) <- names(fit$optresults$mode)
  phi <- plogis(theta_samples$logit_phi)
  survey_id <- filter(key_df, id == i)$survey_id
  data.frame(phi = phi, survey_id = survey_id)
})

bind_rows(phi_samples) %>%
  mutate(
    survey_id = forcats::fct_recode(survey_id,
      "Côte d’Ivoire, PHIA 2017" = "CIV2017PHIA",
      "Malawi, PHIA 2016" = "MWI2016PHIA",
      "Tanzania, PHIA 2017" = "TZA2017PHIA",
      "Zimbabwe, PHIA 2016" = "ZWE2016PHIA",
    )
  ) %>%
  ggplot() +
    geom_histogram(aes(x = phi, y = after_stat(density)), fill = "#56B4E9") +
    stat_function(fun = dbeta, colour = "#009E73", n = 300, args = list(shape1 = 0.5, shape2 = 0.5)) +
    facet_wrap(~ survey_id, ncol = 2) +
    xlim(0, 1) +
    labs(x = "BYM2 proportion parameter", y = "Density", fill = "") +
    geom_col(data = data.frame(x = c(0, 0), y = c(0, 0), type = c("Prior", "Posterior")), aes(x = x, y = y, fill = type)) +
    scale_fill_manual(values = c("#56B4E9", "#009E73")) +
    theme_minimal() +
    theme(
      legend.position = "right"
    )

ggsave("proportion-posteriors.png", h = 3.5, w = 6.25, bg = "white")

#' Lengthscale
lengthscale_index <- key_df %>%
  filter(inf_model %in% c("ck_aghq", "ik_aghq")) %>%
  pull(id) %>%
  as.numeric()

summary(ic_fit[[lengthscale_index[1]]])

exp(-1.4)
exp(2.7)
