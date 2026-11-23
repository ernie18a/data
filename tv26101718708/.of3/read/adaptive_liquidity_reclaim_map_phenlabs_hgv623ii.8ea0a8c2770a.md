Calculation: SwingLow = latest non-missing PivotLow(low, left bars, right bars)
Calculation: SwingHigh = latest non-missing PivotHigh(high, left bars, right bars)
Calculation: BodyAtr = |close - open| / ATR(high, low, close, shorter lookback)
Calculation: VolatilityRatio = ATR(high, low, close, shorter lookback) / SMA(ATR(high, low, close, shorter lookback), longer lookback) if SMA(ATR(high, low, close, shorter lookback), longer lookback) > 0 else neutral volatility ratio
Calculation: AdaptiveImpulse = base impulse * max(lower volatility scale, min(upper volatility scale, VolatilityRatio))
Long: low < SwingLow AND close > SwingLow AND close > open AND BodyAtr >= AdaptiveImpulse AND (filter off OR close(T1, last completed bar) > EMA(close, filter EMA lookback, T1, last completed bar)) AND close - low > tick size AND no earlier Long since the latest PivotLow was confirmed
Short: high > SwingHigh AND close < SwingHigh AND close < open AND BodyAtr >= AdaptiveImpulse AND (filter off OR close(T1, last completed bar) < EMA(close, filter EMA lookback, T1, last completed bar)) AND high - close > tick size AND no earlier Short since the latest PivotHigh was confirmed