Calculation: Relative strength = close / comparison close
Long: EMA(close, chart fast lookback) > EMA(close, chart slow lookback)
Short: EMA(close, chart fast lookback) <= EMA(close, chart slow lookback)
Long: close > VWAP(typical price)
Short: close <= VWAP(typical price)
Long: SMA(close - low, shared lookback) > SMA(high - close, shared lookback)
Short: SMA(high - close, shared lookback) > SMA(close - low, shared lookback)
Long: close > highest(high, lookback)[1]
Short: close < lowest(low, lookback)[1]
Long: high > high[1] AND low > low[1]
Short: high < high[1] AND low < low[1]
Long: EMA(close, shared lookback, T1, still-forming T1 bar sampled on chart bars) > EMA(close, longer lookback, T1, still-forming T1 bar sampled on chart bars)
Short: EMA(close, shared lookback, T1, still-forming T1 bar sampled on chart bars) < EMA(close, longer lookback, T1, still-forming T1 bar sampled on chart bars)
Long: close > EMA(close, shared lookback, T2, still-forming T2 bar sampled on chart bars) AND close > EMA(close, shared lookback, T3, still-forming T3 bar sampled on chart bars)
Long: Relative strength > SMA(Relative strength, lookback)
Short: Relative strength <= SMA(Relative strength, lookback)
Long: volume > SMA(volume, lookback) * volume multiplier AND high > low AND close - low > upper close-position threshold * (high - low)
Short: volume > SMA(volume, lookback) * volume multiplier AND (high = low OR close - low < lower close-position threshold * (high - low))