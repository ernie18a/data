Calculation: Adaptive lookback = max(1, ceiling(long lookback / ADX)); use bars on the configured indicator timeframe, which is independent of the chart timeframe. Evaluate the signal on the last completed bar.
Calculation: Lower threshold = lowest low over the adaptive lookback + (highest high − lowest low over the same lookback) × range fraction.
Calculation: Upper threshold = highest high over the adaptive lookback − (highest high − lowest low over the same lookback) × range fraction.
Calculation: Trend state = bearish when close < lower threshold; bullish when close > upper threshold; otherwise retain the prior state. Initialize neutral; if both conditions hold, bullish is the final state.
Calculation: Bullish arrow = close > upper threshold AND prior trend state < bullish; bearish arrow = close < lower threshold AND prior trend state > bearish.
Long: Bullish arrow AND the most recent earlier arrow is bearish.
Short: Bearish arrow AND the most recent earlier arrow is bullish.
Exit: long, Bearish arrow OR the most recent earlier arrow is bearish.
Exit: short, Bullish arrow OR the most recent earlier arrow is bullish.