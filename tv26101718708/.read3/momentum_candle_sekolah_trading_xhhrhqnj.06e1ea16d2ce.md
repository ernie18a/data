Calculation: Body size = abs(close - open)
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Wick ratio = (upper wick + lower wick) / (body size + upper wick + lower wick)
Calculation: Trend EMA = EMA(close, lookback, T1, bar still forming), calculated on T1 bars and sampled on chart bars
Long: close > trend EMA OR (minimum body threshold is active AND body size >= minimum body threshold AND wick ratio <= maximum wick percentage / 100 AND close > open AND (directional-wick filter is disabled OR lower wick < upper wick) AND (consolidation filter is disabled OR each of the N preceding chart bars has body size < current body size) AND EMA filter is disabled)
Short: close <= trend EMA OR (minimum body threshold is active AND body size >= minimum body threshold AND wick ratio <= maximum wick percentage / 100 AND close < open AND (directional-wick filter is disabled OR upper wick < lower wick) AND (consolidation filter is disabled OR each of the N preceding chart bars has body size < current body size) AND EMA filter is disabled)