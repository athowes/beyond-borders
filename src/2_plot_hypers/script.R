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
    labs(x = "BYM2 proportion", y = "Density", fill = "") +
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

l_samples <- lapply(lengthscale_index, function(i) {
  fit <- ic_fit[[i]]
  samples <- aghq::sample_marginal(fit, M = 1000)
  theta_samples <- data.frame(do.call(cbind, samples$thetasamples))
  names(theta_samples) <- names(fit$optresults$mode)
  l <- exp(theta_samples$log_l)
  survey_id <- filter(key_df, id == i)$survey_id
  inf_model <- filter(key_df, id == i)$inf_model
  data.frame(l = l, survey_id = survey_id, inf_model = inf_model)
})

ck_prior_params <- lapply(tolower(unique(key_df$survey_id)), function(x) {
  sf <- readRDS(paste0("depends/", x, ".rds"))
  D <- centroid_distance(sf)
  # Parameters of the length-scale prior
  if(units(D)$numerator == "m") {
    D <- units::set_units(D, "km")
  }

  D_nonzero <- as.vector(D)[as.vector(D) > 0]
  lb <- quantile(D_nonzero, 0.05)
  ub <- quantile(D_nonzero, 0.95)

  param <- invgamma_prior(lb = lb, ub = ub, plb = 0.05, pub = 0.05)
  data.frame(a = param$a, b = param$b, survey_id = toupper(x), inf_model = "CK")
})

ik_prior_params <- lapply(tolower(unique(key_df$survey_id)), function(x) {
  sf <- readRDS(paste0("depends/", x, ".rds"))
  n <- nrow(sf)
  samples <- sf::st_sample(sf, type = "hexagonal", exact = TRUE, size = rep(10, n))
  S <- sf::st_distance(samples, samples)
  if(units(S)$numerator == "m") {
    S <- units::set_units(S, "km")
  }

  S_nonzero <- as.vector(S)[as.vector(S) > 0]
  lb <- quantile(S_nonzero, 0.05)
  ub <- quantile(S_nonzero, 0.95)

  param <- invgamma_prior(lb = lb, ub = ub, plb = 0.05, pub = 0.05)
  data.frame(a = param$a, b = param$b, survey_id = toupper(x), inf_model = "IK")
})

prior_params <- bind_rows(ck_prior_params, ik_prior_params) %>%
  mutate(
    survey_id = forcats::fct_recode(survey_id,
      "Côte d’Ivoire,\nPHIA 2017" = "CIV2017PHIA",
      "Malawi,\nPHIA 2016" = "MWI2016PHIA",
      "Tanzania,\nPHIA 2017" = "TZA2017PHIA",
      "Zimbabwe,\nPHIA 2016" = "ZWE2016PHIA",
    )
  )

bind_rows(l_samples) %>%
  mutate(
    survey_id = forcats::fct_recode(survey_id,
      "Côte d’Ivoire,\nPHIA 2017" = "CIV2017PHIA",
      "Malawi,\nPHIA 2016" = "MWI2016PHIA",
      "Tanzania,\nPHIA 2017" = "TZA2017PHIA",
      "Zimbabwe,\nPHIA 2016" = "ZWE2016PHIA",
    ),
    inf_model = forcats::fct_recode(inf_model,
      "CK" = "ck_aghq",
      "IK" = "ik_aghq"
    )
  ) %>%
  ggplot() +
  geom_histogram(aes(x = l, y = after_stat(density)), fill = "#56B4E9") +
  geom_function(data = prior_params[1, ], fun = nimble::dinvgamma, args = list(shape = prior_params[1, ]$a, scale = prior_params[1, ]$b), col = "#009E73") +
  geom_function(data = prior_params[2, ], fun = nimble::dinvgamma, args = list(shape = prior_params[2, ]$a, scale = prior_params[2, ]$b), col = "#009E73") +
  geom_function(data = prior_params[3, ], fun = nimble::dinvgamma, args = list(shape = prior_params[3, ]$a, scale = prior_params[3, ]$b), col = "#009E73") +
  geom_function(data = prior_params[4, ], fun = nimble::dinvgamma, args = list(shape = prior_params[4, ]$a, scale = prior_params[4, ]$b), col = "#009E73") +
  geom_function(data = prior_params[5, ], fun = nimble::dinvgamma, args = list(shape = prior_params[5, ]$a, scale = prior_params[5, ]$b), col = "#009E73") +
  geom_function(data = prior_params[6, ], fun = nimble::dinvgamma, args = list(shape = prior_params[6, ]$a, scale = prior_params[6, ]$b), col = "#009E73") +
  geom_function(data = prior_params[7, ], fun = nimble::dinvgamma, args = list(shape = prior_params[7, ]$a, scale = prior_params[7, ]$b), col = "#009E73") +
  geom_function(data = prior_params[8, ], fun = nimble::dinvgamma, args = list(shape = prior_params[8, ]$a, scale = prior_params[8, ]$b), col = "#009E73") +
  facet_grid(survey_id ~ inf_model, scales = "free") +
  labs(x = "Lengthscale (km)", y = "Density", fill = "") +
  geom_col(data = data.frame(x = c(0, 0), y = c(0, 0), type = c("Prior", "Posterior")), aes(x = x, y = y, fill = type)) +
  scale_fill_manual(values = c("#56B4E9", "#009E73")) +
  theme_minimal() +
  theme(
    legend.position = "bottom"
  )

ggsave("lengthscale-posteriors.png", h = 4.5, w = 6.25, bg = "white")
