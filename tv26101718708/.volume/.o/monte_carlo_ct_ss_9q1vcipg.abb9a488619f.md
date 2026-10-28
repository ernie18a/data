Calculation: Relative volume = current volume / rolling mean volume
Calculation: Momentum = close rate of change over a short lookback
Calculation: Naive Bayes win probability = P(up | current relative volume, current momentum), using Gaussian feature densities assumed independent; estimate each feature’s mean and variance separately for up bars (close > previous close) and non-up bars over the training lookback, and use the up-bar fraction as the prior
Long: Naive Bayes win probability > 0.5
Short: Naive Bayes win probability <= 0.5