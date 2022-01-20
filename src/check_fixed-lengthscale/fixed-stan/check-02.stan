data {
  int<lower=0> n; // Number of regions
  int y[n]; // Vector of observed responses
  int m[n]; // Vector of sample sizes
  vector[n] mu; // Prior mean vector
  matrix[n, n] K; // Gram matrix
}

parameters {
  real beta_0; // Intercept
  vector[n] phi; // Spatial effects
  real<lower=0> sigma_phi; // Standard deviation of spatial effects
}

transformed parameters {
  vector[n] eta = beta_0 + sigma_phi * phi;
}

model {
  sigma_phi ~ normal(0, 2.5); // Weakly informative prior
  beta_0 ~ normal(-2, 1);
  phi ~ multi_normal(mu, K);
  y ~ binomial_logit(m, eta); 
}

generated quantities {
  real tau_phi = 1 / sigma_phi^2; // Precision of spatial effects
  vector[n] rho = inv_logit(beta_0 + sigma_phi * phi);
}