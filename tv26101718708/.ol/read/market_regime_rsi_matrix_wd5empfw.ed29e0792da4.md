Calculation: Master RSI = weighted average of RSI values from the monitored timeframes, using each timeframe's configured weight; for timeframes higher than the chart, use the last completed bar, and for lower timeframes use the latest available bar within the chart bar.
Calculation: Consensus score = absolute difference between the counts of monitored timeframes with RSI ≥ 50 and RSI < 50, divided by the total number of monitored timeframes, multiplied by 100.
Calculation: Fast and slow trend EMAs = EMAs of Master RSI, with the fast EMA using a shorter smoothing period than the slow EMA.
Calculation: Trend strength value = the smaller of 10 times the absolute difference between the fast and slow trend EMAs, and 100.
Calculation: RSI Fibonacci levels = levels between the lowest and highest Master RSI over a lookback, using the standard 0.236, 0.382, 0.500, and 0.618 ratios.
Calculation: Probability score = 0.40 × consensus score + 0.30 × trend strength value + 0.20 × RSI Fibonacci position score + 0.10 × (2 × absolute difference between Master RSI and 50); the Fibonacci position score is 100 at or above the 0.618 level, 75 at or above 0.500, 50 at or above 0.382, 25 at or above 0.236, and 0 otherwise.
Long: Master RSI ≥ 50
Long: The number of monitored timeframes with RSI ≥ 50 is greater than the number with RSI < 50
Long: Fast trend EMA > slow trend EMA
Long: Consensus score ≥ 70 AND fast trend EMA > slow trend EMA AND probability score ≥ 70 AND Master RSI ≥ 60
Short: Master RSI < 50
Short: The number of monitored timeframes with RSI < 50 is greater than the number with RSI ≥ 50
Short: Fast trend EMA < slow trend EMA
Short: Consensus score ≥ 70 AND fast trend EMA < slow trend EMA AND probability score ≥ 70 AND Master RSI ≤ 40