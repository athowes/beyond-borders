// cov_sample_average.stan

functions {
  matrix cov_matern32(matrix D, real l) {
    int n = rows(D);
    matrix[n, n] K;
    real norm_K;
    real sqrt3;
    sqrt3 = sqrt(3.0);

    for(i in 1:(n - 1)){
      // Diagonal entries (apart from the last)
      K[i, i] = 1;
      for(j in (i + 1):n){
        // Off-diagonal entries
        norm_K = D[i, j] / l;
        K[i, j] = (1 + sqrt3 * norm_K) * exp(-sqrt3 * norm_K); // Fill lower triangle
        K[j, i] = K[i, j]; // Fill upper triangle
      }
    }
    K[n, n] = 1;

    return(K);
  }

  matrix cov_sample_average(matrix S, real l, int n, int[] start_index, int[] sample_lengths, int total_samples) {
    matrix[n, n] K;
    matrix[total_samples, total_samples] kS = cov_matern32(S, l);

    for(i in 1:(n - 1)) {
      // Diagonal entries (apart from the last)
      int start_i = start_index[i];
      int length_i = sample_lengths[i];
      K[i, i] = mean(block(kS, start_i, start_i, length_i, length_i));
      for(j in (i + 1):n) {
        // Off-diagonal entries
        K[i, j] = mean(block(kS, start_i, start_index[j], length_i, sample_lengths[j]));
        K[j, i] = K[i, j];
      }
    }
    K[n, n] = mean(block(kS, start_index[n], start_index[n], sample_lengths[n], sample_lengths[n]));

    return(K);
  }

  matrix cov_sample_average_old(int n, int L, real l, matrix S) {
    matrix[n, n] K;
    matrix[L * n, L * n] kS = cov_matern32(S, l);

    // Diagonal entries
    for(i in 1:n){
      K[i, i] = mean(kS[(L * (i - 1) + 1):(i * L), (L * (i - 1) + 1):(i * L)]);
    }

    // Off-diagonal entries
    for(i in 1:(n - 1)) {
      for(j in (i + 1):n) {
        K[i, j] = mean(kS[(L * (i - 1) + 1):(i * L), (L * (j - 1) + 1):(j * L)]);
        K[j, i] = K[i, j];
      }
    }
    return(K);
  }
}
