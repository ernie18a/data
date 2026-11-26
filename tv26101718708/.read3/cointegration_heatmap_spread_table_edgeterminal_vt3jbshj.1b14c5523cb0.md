Calculation: Pair Z-score = (latest OLS residual minus the mean of the last residual-lookback residuals) divided by their population standard deviation; each residual is the second symbol’s percentage return minus (OLS intercept plus OLS slope times the first symbol’s percentage return), with slope and intercept fitted over all available aligned returns up to an optional regression-lookback; returns are calculated from the last completed T1 close and the preceding completed T1 close, and the calculation updates on chart bars as completed T1 return samples arrive
Long: at least two aligned return observations AND Pair Z-score < -entry threshold
Short: at least two aligned return observations AND Pair Z-score > entry threshold
Exit: Long, Pair Z-score >= -entry threshold AND Pair Z-score <= entry threshold
Exit: Short, Pair Z-score >= -entry threshold AND Pair Z-score <= entry threshold
Calculation: Pair residual Z-score = (latest residual - mean of latest P2 residuals) / population standard deviation of latest P2 residuals, where each residual is the second asset's T1 percentage return minus (intercept + slope × first asset's T1 percentage return), slope = covariance of paired returns / variance of first asset's returns, and intercept = mean of second asset's returns - slope × mean of first asset's returns, fitted over all collected paired returns or the latest P3 paired returns when the history limit is enabled
Long: second asset of the pair when Pair residual Z-score < -P1
Short: first asset of the pair when Pair residual Z-score < -P1
Long: first asset of the pair when Pair residual Z-score > P1
Short: second asset of the pair when Pair residual Z-score > P1
Exit: long spread, absolute Pair residual Z-score < P4
Exit: short spread, absolute Pair residual Z-score < P4