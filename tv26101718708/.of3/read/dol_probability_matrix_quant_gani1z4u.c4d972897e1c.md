Calculation: candle volume delta = volume if close > open, -volume if close < open, 0 otherwise
Long: EMA(candle volume delta, lookback) > 0
Short: EMA(candle volume delta, lookback) <= 0