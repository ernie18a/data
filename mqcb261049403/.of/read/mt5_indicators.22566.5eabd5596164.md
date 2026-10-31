Calculation: Smoothed candle = apply the same selected moving-average method and parameters independently to open and close; use the previous bar's smoothed close as the candle open when abs(open - close) <= the gap threshold, otherwise use the current smoothed open. The candle close is the current smoothed close.
Calculation: Trend = +1 when the smoothed candle close > its open, -1 when the smoothed candle close < its open, and the previous trend when they are equal; initialize trend to 0.
Calculation: Higher-timeframe trend = calculate the same trend on higher-timeframe bars, using the bar still forming at the first chart bar of each higher-timeframe bar; retain that sampled trend until the next higher-timeframe bar begins.
Long: Trend > 0 AND previous trend <= 0
Short: Trend < 0 AND previous trend >= 0
Long: Higher-timeframe trend > 0
Short: Higher-timeframe trend < 0