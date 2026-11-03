Calculation: Normalized momentum flow = 100 × (close − close at the momentum lookback) ÷ EMA(high − low, same lookback) + 10,000 × flow boost × (shorter-lookback EMA of close − longer-lookback EMA of close) ÷ close
Calculation: Positive bias = EMA over the smoothing lookback of the sum of the positive parts of normalized momentum flow on this bar and the previous bar
Calculation: Negative bias = EMA over the smoothing lookback of the sum of the negative parts of normalized momentum flow on this bar and the previous bar
Calculation: Higher-timeframe bias = EMA of positive bias plus negative bias, calculated on a higher timeframe using its still-forming bar
Long: Positive bias > 0 OR higher-timeframe bias > 0
Short: Negative bias < 0 OR higher-timeframe bias <= 0