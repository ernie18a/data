Calculation: Elephant bar = high - low > ATR(ATR lookback) * range multiplier AND (high > low ? abs(close - open) / (high - low) : 0) > minimum body fraction
Calculation: Relative distance from long-term SMA = abs(close - SMA(close, long-term trend lookback)) / SMA(close, long-term trend lookback)
Long: Elephant bar AND close > open
Short: Elephant bar AND close < open
Long: low > high[2]
Short: high < low[2]
Long: close crosses above EMA(source, lookback, T1, current still-forming bar), sampled on chart bars
Short: close crosses below EMA(source, lookback, T1, current still-forming bar), sampled on chart bars
Long: close > SMA(close, momentum lookback) AND NOT (Elephant bar AND close < open)
Short: close <= SMA(close, momentum lookback) AND NOT (Elephant bar AND close > open)
Long: SMA(close, shorter trend lookback) > SMA(close, shorter trend lookback)[1]
Short: SMA(close, shorter trend lookback) <= SMA(close, shorter trend lookback)[1]
Long: SMA(close, shorter trend lookback) > SMA(close, long-term trend lookback) AND Relative distance from long-term SMA >= distance threshold
Short: SMA(close, shorter trend lookback) < SMA(close, long-term trend lookback) AND Relative distance from long-term SMA >= distance threshold