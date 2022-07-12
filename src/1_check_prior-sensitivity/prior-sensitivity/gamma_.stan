functions {
  real xbinomial_logit_lpdf(real y, real m, real eta) {
    real dens = lchoose(m, y) + y * log(inv_logit(eta)) + (m - y) * log(1 - inv_logit(eta));
    real jacobian = log(inv_logit(eta)) + log(inv_logit(-eta)); // Alternative: eta - 2 * log(1 + exp(eta))
    return dens + jacobian;
  }
  
  matrix cov_matern32(matrix D, real l) {
    int n = rows(D);
    matrix[n, n] K;
    real norm_K;
    real sqrt3;
    sqrt3 = sqrt(3.0);
    
    // Diagonal entries
    for(i in 1:n){
      K[i, i] = 1;
    }
    
    for(i in 1:(n - 1)){
      for(j in (i + 1):n){
        norm_K = D[i, j] / l;
        K[i, j] = (1 + sqrt3 * norm_K) * exp(-sqrt3 * norm_K); // Fill lower triangle
        K[j, i] = K[i, j]; // Fill upper triangle
      }
    }
    return(K);
  }
}

data {
  int<lower=0> n; // Number of regions
  vector[n] y; // Vector of observed responses
  vector[n] m; // Vector of sample sizes
  vector[n] mu; // Prior mean vector
  matrix[n, n] D; // Distances between centroids
}

parameters {
  real beta_0; // Intercept
  vector[n] phi; // Spatial effects
  real<lower=0> sigma_phi; // Standard deviation of spatial effects
  real<lower=0> l; // Kernel lengthscale
}

transformed parameters {
  vector[n] eta = beta_0 + sigma_phi * phi;
}

model {
  matrix[n, n] K = cov_matern32(D, l);
  l ~ gamma(1, 1);
  sigma_phi ~ normal(0, 2.5); // Weakly informative prior
  beta_0 ~ normal(-2, 1);
  phi ~ multi_normal(mu, K);
  for(i in 1:n) {
    y[i] ~ xbinomial_logit(m[i], eta[i]); 
  }
}

generated quantities {
  real tau_phi = 1 / sigma_phi^2; // Precision of spatial effects
  vector[n] rho = inv_logit(beta_0 + sigma_phi * phi);
  vector[n] log_lik;
  for (i in 1:n) {
    log_lik[i] = xbinomial_logit_lpdf(y[i] | m[i], eta[i]);
  }
}