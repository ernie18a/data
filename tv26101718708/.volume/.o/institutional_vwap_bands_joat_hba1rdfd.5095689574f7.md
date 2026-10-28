Calculation: Anchored VWAP = volume-weighted average of the configured price source, accumulated from the start of the configured session, week, or month and including the current bar.
Calculation: VWAP standard deviation = square root of the volume-weighted mean of squared source price minus the square of Anchored VWAP, accumulated over the same anchor period and including the current bar.
Calculation: VWAP z-score = (close − Anchored VWAP) / VWAP standard deviation; use 0 when standard deviation is 0.
Long: (previous bar z-score ≤ −configured reversion threshold AND current z-score > previous bar z-score AND close > open OR close ≥ EMA(close, configured trend lookback) AND close crosses above Anchored VWAP) AND no short signal on this bar AND configured minimum gap since the prior signal has elapsed
Short: (previous bar z-score ≥ configured reversion threshold AND current z-score < previous bar z-score AND close < open OR close < EMA(close, configured trend lookback) AND close crosses below Anchored VWAP) AND configured minimum gap since the prior signal has elapsed
Exit: long, high ≥ first target OR low ≤ stop
Exit: short, low ≤ first target OR high ≥ stop