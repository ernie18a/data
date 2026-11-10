Calculation: Timeframe readings = for each enabled timeframe equal to or higher than the chart timeframe, calculate the shorter-period EMA of close, longer-period EMA of close, RSI of close, and close; use either the last completed bar of that timeframe or its still-forming bar, consistently across timeframes. A timeframe is valid when all four readings are available.
Calculation: Timeframe score = sum of three contributions: +1 if the shorter-period EMA is above the longer-period EMA, -1 if below, otherwise 0; +1 if close is above the longer-period EMA, -1 if below, otherwise 0; +1 if RSI is above its midpoint, -1 if below, otherwise 0.
Calculation: Bullish count = number of valid timeframes whose score is at least the positive trend threshold.
Calculation: Bearish count = number of valid timeframes whose score is at most the negative trend threshold.
Long: A valid timeframe's shorter-period EMA > its longer-period EMA.
Long: A valid timeframe's close > its longer-period EMA.
Long: A valid timeframe's RSI > its midpoint.
Long: A valid timeframe's score > 0.
Long: Bullish count > bearish count.
Long: Number of valid timeframes > 0 AND bullish count = number of valid timeframes.
Short: A valid timeframe's shorter-period EMA < its longer-period EMA.
Short: A valid timeframe's close < its longer-period EMA.
Short: A valid timeframe's RSI < its midpoint.
Short: A valid timeframe's score < 0.
Short: Bearish count > bullish count.
Short: Number of valid timeframes > 0 AND bearish count = number of valid timeframes.