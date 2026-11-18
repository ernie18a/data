Calculation: Smoothed RSI = EMA(RSI(selected data field, RSI lookback), intermediate EMA lookback) on chart bars
Calculation: Main measure = EMA(Smoothed RSI, longer EMA lookback) on chart bars
Calculation: Confirmation measure = EMA(Main measure, shorter EMA lookback) on chart bars
Calculation: Difference = Main measure - Confirmation measure
Calculation: Mean absolute difference = EMA(ABS(Difference), longest EMA lookback) on chart bars
Calculation: Main measure change = Main measure - Main measure[1]
Calculation: T1 trend measure = EMA(RSI(selected data field, RSI lookback), intermediate EMA lookback) on T1 bars using the still-forming T1 bar
Calculation: T1 smoothed measure = EMA(T1 trend measure sampled on chart bars, separate short EMA lookback) on chart bars
Long: Difference > Mean absolute difference AND Main measure change > 0
Long: Difference > 0 AND NOT (Difference > Mean absolute difference AND Main measure change > 0)
Short: Difference < -Mean absolute difference AND Main measure change < 0
Short: Difference < 0 AND NOT (Difference < -Mean absolute difference AND Main measure change < 0)
Long: T1 smoothed measure > T1 smoothed measure[1]
Short: T1 smoothed measure <= T1 smoothed measure[1]
Long: Main measure change > 0 AND Main measure change > Main measure change[1]
Short: Main measure change < 0 AND Main measure change < Main measure change[1]
Long: Difference > 0 AND Difference[1] <= 0 AND Main measure > Main measure[1]
Short: Difference < 0 AND Difference[1] >= 0 AND Main measure < Main measure[1]
Long: Difference > Mean absolute difference
Short: Difference < -Mean absolute difference
Long: NOT (Main measure change > 0 AND Main measure change > Main measure change[1]) AND NOT (Main measure change < 0 AND Main measure change < Main measure change[1]) AND Difference >= 0
Short: NOT (Main measure change > 0 AND Main measure change > Main measure change[1]) AND NOT (Main measure change < 0 AND Main measure change < Main measure change[1]) AND Difference < 0