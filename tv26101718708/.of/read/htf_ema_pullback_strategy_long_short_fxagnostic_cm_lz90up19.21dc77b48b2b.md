Calculation: Pullback touch = the lowest, over the lookback, of |bar low − short EMA| / short EMA is at most the pullback tolerance
Calculation: Bullish candle confirmation = bullish engulfing (close > open, open ≤ previous close, previous open > previous close, and close ≥ previous open) OR lower wick > 40% of bar range
Calculation: Bearish candle confirmation = bearish engulfing (close < open, open ≥ previous close, previous open < previous close, and close ≤ previous open) OR upper wick > 40% of bar range
Calculation: MACD histogram = (fast EMA of close − slow EMA of close) − EMA of that difference using the signal length
Calculation: Pivot low/high = a bar low/high lower/higher than the specified number of bars on both sides; use the most recently confirmed pivot
Long: higher-timeframe short EMA > higher-timeframe long EMA AND Pullback touch AND Bullish candle confirmation AND MACD histogram > previous bar's MACD histogram AND close > chart-timeframe short EMA AND close > most recently confirmed pivot low
Short: higher-timeframe short EMA < higher-timeframe long EMA AND Pullback touch AND Bearish candle confirmation AND MACD histogram < previous bar's MACD histogram AND close < chart-timeframe short EMA AND close < most recently confirmed pivot high
Exit: long, bar low ≤ most recently confirmed pivot low OR bar high ≥ signal close + (signal close − pivot low) × target multiple
Exit: short, bar high ≥ most recently confirmed pivot high OR bar low ≤ signal close − (pivot high − signal close) × target multiple