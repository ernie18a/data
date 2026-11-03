Calculation: Bullish structure = the two most recent confirmed pivot highs and the two most recent confirmed pivot lows are both rising.
Calculation: Bearish structure = the two most recent confirmed pivot highs and the two most recent confirmed pivot lows are both falling.
Calculation: ROC = (close − close from the configured lookback bars earlier) / that earlier close × 100.
Calculation: For each displayed aggregated timeframe, calculate scores from its close, open, ROC, and pivot structure: bullish score = 1 each for bullish structure, ROC > 0, and close > open; bearish score = 1 each for bearish structure, ROC < 0, and close < open. Use the last completed bar when the timeframe is higher than the chart timeframe and the bar still forming when it is lower.
Long: Bullish score > bearish score on a displayed aggregated timeframe.
Short: Bearish score > bullish score on a displayed aggregated timeframe.