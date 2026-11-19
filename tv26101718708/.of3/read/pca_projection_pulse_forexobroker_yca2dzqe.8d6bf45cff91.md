Calculation: PCA projection = z-score(close, lookback) * u_close + z-score(volume, lookback) * u_volume, where (u_close, u_volume) is the normalized vector (λ1 - variance(volume, lookback), covariance(close, volume, lookback)); λ1 is the largest eigenvalue of the rolling covariance matrix of raw close and volume, and a zero vector remains zero.
Long: PCA projection >= threshold AND PCA projection[1] < threshold
Short: PCA projection <= -threshold AND PCA projection[1] > -threshold
Long: PCA projection >= threshold AND PCA projection[1] < threshold AND position is flat or short AND cooldown elapsed AND bar is confirmed
Short: PCA projection <= -threshold AND PCA projection[1] > -threshold AND position is flat or long AND cooldown elapsed