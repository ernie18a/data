Calculation: volatility spread = selected volatility-index close from T1, sampled on chart bars with lookahead off (last completed T1 bar historically; still-forming T1 bar in real time), minus stdev(log(close / close[1]), lookback) × sqrt(annualization factor) × 100
Long: volatility spread > stdev(volatility spread, lookback) × threshold multiplier
Short: volatility spread < −stdev(volatility spread, lookback) × threshold multiplier
Exit: long, volatility spread crosses above zero
Exit: short, volatility spread crosses below zero
Calculation: Volatility spread = T1 volatility index close - annualized historical volatility of chart close over P1 bars
Calculation: Dynamic threshold = standard deviation of volatility spread over P1 bars * P2
Long: Volatility spread > Dynamic threshold
Short: Volatility spread < -Dynamic threshold
Exit: Long, volatility spread crosses above zero
Exit: Short, volatility spread crosses below zero