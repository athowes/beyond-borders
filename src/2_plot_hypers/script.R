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

summary(ic_fit[[bym2_index[1]]])

#' Lengthscale
lengthscale_index <- key_df %>%
  filter(inf_model %in% c("ck_aghq", "ik_aghq")) %>%
  pull(id) %>%
  as.numeric()

summary(ic_fit[[lengthscale_index[1]]])

exp(-1.4)
exp(2.7)
