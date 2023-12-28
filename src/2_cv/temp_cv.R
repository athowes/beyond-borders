type <- "loo"
survey <- "mwi2016phia"
inf_function <- arealutils::iid_aghq

message("Begin ", toupper(type), " cross-valdiation of ", f, " to the survey ", toupper(survey))

sf <- readRDS(paste0("depends/", survey, ".rds"))

index <- which(!is.na(sf$y))
n <- length(index)
training_indices <- vector(mode = "list", length = n)

if(type == "loo"){
  for(i in index){
    training_indices[[i]] <- list(held_out = i, predict_on = i)
  }
}

if(type == "sloo"){
  nb <- sf_to_nb(sf)
  nb <- lapply(nb, FUN = function(region) {
    if(region[1] == 0) {
      return(NULL)
    } else {
      return(region)
    }
  })
  for(i in index) {
    sf_new <- sf
    i_neighbours <- nb[[i]]
    held_out <- c(i, i_neighbours)
    training_indices[[i]] <- list(held_out = held_out, predict_on = i)
  }
}

result <- lapply(training_indices, function(x) {
  capture.output(fit <- inf_function(sf, ii = NULL))
  samples <- aghq::sample_marginal(fit, M = 1000)
  x_samples <- samples$samps
  beta_0_samples <- x_samples[1, ]
  u_samples <- x_samples[1 + x$predict_on, ]
  rho_samples <- plogis(u_samples + beta_0_samples)
  est <- sf$y[x$predict_on] / sf$n_obs[x$predict_on]
  out <- summaries(rho_samples, est)
  out[["index"]] <- x$predict_on
  return(out)
})

result <- bind_rows(result)
result$inf_model <- f
result$type <- type
result$survey <- survey

result %>%
  group_by(survey) %>%
  summarise(mean_crps = 1000 * mean(crps))
