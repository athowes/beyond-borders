geometry <- pars$geometry[1]
sim_model <- pars$sim_model[1]
inf_function <- pars$inf_function[1]
inf_function <- arealutils::iid_aghq

if(f %in% c("fck_aghq", "ck_aghq") & geometry == "2") {
  message("The centroid kernel is not defined for geometry 2!")
  return(NULL)
}

data <- readRDS(paste0("depends/data_", sim_model, "_", geometry, ".rds"))

message("Fitting ", length(data), " ", f, " models to ", sim_model, " simulated data on the ", geometry, " geometry...")

.g <- function(x) {
  capture.output(fit <- inf_function(x$sf))
  samples_aghq <- aghq::sample_marginal(fit, 200)
  x_samples <- samples_aghq$samps

  # Want to keep only beta_0 and u. Omit w in the case of BYM2
  x_samples <- x_samples[rownames(x_samples) %in% c("beta_0", "u"), ]
  theta_samples <- do.call(rbind, samples_aghq$thetasamples)

  # Create prevalence samples
  beta_0_samples <- x_samples[1, ]
  u_samples <- x_samples[-1, ]
  rho_samples <- plogis(u_samples + matrix(rep(beta_0_samples, each = nrow(u_samples)), nrow = nrow(u_samples)))

  theta_samples <- do.call(rbind, samples_aghq$thetasamples)

  samples <- rbind(x_samples, rho_samples, theta_samples)
  rownames(samples) <- NULL

  # beta_0 is set to -2 and sigma_phi is set to 1
  true_values <- c(-2, x$u, x$rho, log(1))

  # The phi hyperparameter of BYM2 is not set
  if(f %in% c("bym2_aghq")) {
    true_values <- c(true_values, NA)
  }

  # The lengthscale parameter is set to 2.5 (only in the IK simulated data case)
  if(f %in% c("ck_aghq", "ik_aghq")) {
    if(sim_model == "ik") {
      true_values <- c(true_values, log(2.5))
    } else {
      true_values <- c(true_values, NA)
    }
  }

  result <- purrr::map2_df(split(samples, seq(nrow(samples))), true_values, summaries)
  result$par <- c("beta_0", paste0("u", 1:length(x$u)), paste0("rho", 1:length(x$u)), names(fit$optresults$mode))
  return(result)
}

results <- purrr::map(data, safely(.g))
results <- keep(results, ~is.null(.x$error)) %>%
  map(results)

df <- data.frame(dplyr::bind_rows(results, .id = "replicate"))
df$replicate <- as.numeric(df$replicate)
df$geometry <- geometry
df$sim_model <- sim_model
