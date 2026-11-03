Calculation: Per-timeframe phase vector = unit-normalized pair ((Stochastic %K − 50)/50, (RSI − 50)/50), using the prior completed bar on the chart timeframe and on each of three higher timeframes
Calculation: Fused vector = weighted sum of the four per-timeframe phase vectors, with weights normalized to sum to one
Long: fused vector x < 0 AND fused vector y < 0
Short: fused vector x >= 0 AND fused vector y >= 0