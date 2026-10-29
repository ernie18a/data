Calculation: Directional state = bullish when (higher-timeframe close − previous higher-timeframe close) / previous higher-timeframe close > threshold; bearish when it is < −threshold; otherwise retain the prior state. Use the higher-timeframe bar still forming.
Long: Directional state delayed by the post-signal delay is bullish AND the Hull moving average is greater than its value two bars ago AND there is no open position
Short: Directional state delayed by the post-signal delay is not bullish AND the Hull moving average is less than its value two bars ago AND there is no open position
Exit: Short, directional state is bullish AND close < low from the close-position delay bars ago
Exit: Long, directional state is not bullish AND close > high from the close-position delay bars ago