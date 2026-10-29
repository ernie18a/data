Calculation: Imbalance score = 100 × the rolling sum of volume × close-location value divided by rolling sum of volume, where close-location value = 2 × (close − low) / max(high − low, minimum tick) − 1
Calculation: Upper threshold = rolling upper percentile of the imbalance score
Calculation: Lower threshold = rolling lower percentile of the imbalance score
Long: Previous completed chart bar's imbalance score > its upper threshold AND previous completed chart bar's close > its simple moving average AND bars since prior long signal >= cooldown
Short: Previous completed chart bar's imbalance score < its lower threshold AND previous completed chart bar's close < its simple moving average AND bars since prior short signal >= cooldown