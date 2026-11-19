Calculation: Pair residual Z-score = (latest residual - mean of latest P2 residuals) / population standard deviation of latest P2 residuals, where each residual is the second asset's T1 percentage return minus (intercept + slope × first asset's T1 percentage return), slope = covariance of paired returns / variance of first asset's returns, and intercept = mean of second asset's returns - slope × mean of first asset's returns, fitted over all collected paired returns or the latest P3 paired returns when the history limit is enabled
Long: second asset of the pair when Pair residual Z-score < -P1
Short: first asset of the pair when Pair residual Z-score < -P1
Long: first asset of the pair when Pair residual Z-score > P1
Short: second asset of the pair when Pair residual Z-score > P1
Exit: long spread, absolute Pair residual Z-score < P4
Exit: short spread, absolute Pair residual Z-score < P4