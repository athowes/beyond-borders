survey <- "zwe2016phia"
inf_function <- arealutils::ik_aghq
f <- "ik_aghq"

message("Begin fitting of ", f, " to the survey ", toupper(survey))
sf <- readRDS(paste0("depends/", survey, ".rds"))
capture.output(fit <- inf_function(sf, ii = NULL))
samples <- aghq::sample_marginal(fit, M = 1000)
x_samples <- samples$samps
u_samples <- x_samples[rownames(x_samples) == "u", ]
beta_0_samples <- x_samples[1, ]
rho_samples <- plogis(u_samples + beta_0_samples)
rho_summaries <- data.frame(t(apply(rho_samples, 1, function(x) c(mean(x), quantile(x, c(0.5, 0.025, 0.975))))), row.names = NULL)

names(rho_summaries) <- c("mean", "mode", "lower", "upper")
result <- bind_cols(select(sf, survey_id, area_name, y, n_obs), rho_summaries)
result$inf_model <- f
result
