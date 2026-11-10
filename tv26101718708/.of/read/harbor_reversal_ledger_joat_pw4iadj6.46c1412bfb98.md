Calculation: Higher-timeframe bullish pattern = enabled bullish engulfing OR enabled bullish pin bar, using the last completed higher-timeframe bar; bullish engulfing requires its close > open, the preceding completed higher-timeframe bar's close < open, its close >= the preceding open, and its open <= the preceding close; bullish pin bar requires min(open, close) - low > range × wick threshold AND abs(close - open) < range × body threshold.
Calculation: Higher-timeframe bearish pattern = enabled bearish engulfing OR enabled bearish pin bar, using the last completed higher-timeframe bar; bearish engulfing requires its close < open, the preceding completed higher-timeframe bar's close > open, its close <= the preceding open, and its open >= the preceding close; bearish pin bar requires high - max(open, close) > range × wick threshold AND abs(close - open) < range × body threshold. Use the same thresholds as for the bullish pin bar.
Calculation: Bullish divergence = a newly confirmed RSI pivot low has a lower price low and a higher RSI than the preceding confirmed RSI pivot low; compare price lows at the RSI pivot bars and evaluate on the confirmation bar.
Calculation: Bearish divergence = a newly confirmed RSI pivot high has a higher price high and a lower RSI than the preceding confirmed RSI pivot high; compare price highs at the RSI pivot bars and evaluate on the confirmation bar. Use the same RSI and pivot parameters as for bullish divergence.
Calculation: Bullish confluence = pattern weight if the higher-timeframe bullish pattern is present, otherwise zero, plus divergence weight if bullish divergence is present, otherwise zero, plus distance weight × max(0, 1 - (low - lowest low over the distance lookback) / (ATR × distance multiplier)).
Calculation: Bearish confluence = pattern weight if the higher-timeframe bearish pattern is present, otherwise zero, plus divergence weight if bearish divergence is present, otherwise zero, plus distance weight × max(0, 1 - (highest high over the distance lookback - high) / (ATR × distance multiplier)). Use the same weights, distance lookback, ATR and distance multiplier as for bullish confluence.
Long: Higher-timeframe bullish pattern = true.
Short: Higher-timeframe bearish pattern = true.
Long: Bullish divergence = true.
Short: Bearish divergence = true.
Long: Bullish confluence >= bearish confluence.
Short: Bullish confluence < bearish confluence.
Long: RSI >= RSI midpoint.
Short: RSI < RSI midpoint.
Long: Last completed higher-timeframe close >= open.
Short: Last completed higher-timeframe close < open.
Long: Higher-timeframe bullish pattern = true OR (higher-timeframe bearish pattern = false AND last completed higher-timeframe close > open).
Short: Higher-timeframe bullish pattern = false AND (higher-timeframe bearish pattern = true OR last completed higher-timeframe close < open).