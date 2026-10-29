Calculation: SSL NRTR trend state = On the configured indicator timeframe (higher or lower than the chart timeframe), using the last completed bar: bearish if close < the smoothed low; bullish if close > the smoothed high; otherwise neutral. Smooth highs and lows with the same configurable moving-average method and lookback.
Long: Current SSL NRTR trend state = bullish AND prior state ≠ bullish
Short: Current SSL NRTR trend state = bearish AND prior state ≠ bearish
Exit: long, SSL NRTR trend state = bearish OR low ≤ entry price − stop distance OR high ≥ entry price + target distance
Exit: short, SSL NRTR trend state = bullish OR high ≥ entry price + stop distance OR low ≤ entry price − target distance