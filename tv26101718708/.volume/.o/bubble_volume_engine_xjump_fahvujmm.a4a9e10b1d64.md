Calculation: Lower-timeframe volume delta = the current chart bar’s net up-volume minus down-volume, aggregated from lower-timeframe bars.
Calculation: Signed delta z-score = (volume delta − its rolling mean) / its rolling standard deviation; delta strength = its absolute value.
Calculation: Rolling CVD = sum of volume delta over a rolling lookback.
Calculation: Relative volume = current bar volume / its rolling average volume.
Calculation: Bullish divergence = a confirmed price pivot low is lower than the previous paired price pivot low while its paired rolling-CVD pivot low is higher; bearish divergence = a confirmed price pivot high is higher than the previous paired price pivot high while its paired rolling-CVD pivot high is lower. Pivot lookback is the same for price and CVD; each pivot is confirmed using bars on both sides.
Calculation: Candle body ratio = |close − open| / (high − low), using the minimum price increment when the range is zero. Upper/lower wick ratios are the respective wick lengths divided by that same range.
Calculation: Confluence score = clamp to 0–5 the sum of five Boolean points (delta aligned with candle direction, relative volume passes its threshold, delta strength passes its threshold, either liquidity sweep occurs, and candle structure passes its filter), plus one for delta-aligned higher-timeframe trend and one for delta-aligned intrabar VWAP; subtract one for opposing higher-timeframe trend. A liquidity absorption raises the score to at least 4. The higher-timeframe close and EMA use the same higher-timeframe bar, which may still be forming; the EMA lookback is longer than the delta z-score lookback.
Long: Positive volume delta AND absolute delta strength or absolute volume delta exceeds its rolling percentile filter AND relative volume passes its threshold AND the configured bubble display and size filters pass AND (the chart bar is confirmed or confirmed-only is disabled).
Short: Negative volume delta AND absolute delta strength or absolute volume delta exceeds its rolling percentile filter AND relative volume passes its threshold AND the configured bubble display and size filters pass AND (the chart bar is confirmed or confirmed-only is disabled).
Long: Negative volume delta AND close >= open AND low sweeps below the lowest low of prior bars over the sweep lookback and close is above that prior low AND delta strength passes its absorption threshold AND relative volume passes its threshold.
Short: Positive volume delta AND close < open AND high sweeps above the highest high of prior bars over the sweep lookback and close is below that prior high AND delta strength passes its absorption threshold AND relative volume passes its threshold.
Long: Bullish divergence.
Short: Bearish divergence.
Long: close >= open AND volume is below 0.75 times its rolling average AND candle body ratio < 0.35.
Short: close < open AND volume is below 0.75 times its rolling average AND candle body ratio < 0.35.
Short: close >= open AND upper wick ratio >= 0.5 AND volume > 1.5 times its rolling average AND candle body ratio < 0.30.
Long: close < open AND lower wick ratio >= 0.5 AND volume > 1.5 times its rolling average AND candle body ratio < 0.30.
Long: Confluence score >= 4 AND volume delta > 0 AND no absorption, divergence, or VSA pattern is active.
Short: Confluence score >= 4 AND volume delta < 0 AND no absorption, divergence, or VSA pattern is active.