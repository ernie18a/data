Calculation: Directional pressure = EMA(100 * (0.35 * (if high > low then (close - open) / (high - low) else 0) + 0.25 * (if high > low then 2 * (close - low) / (high - low) - 1 else 0) + 0.30 * (if ATR(ATR lookback) > 0 then clamp((close - close[momentum lookback]) / (2.5 * ATR(ATR lookback)), -1, 1) else 0) + 0.10 * Efficiency Ratio(close, efficiency lookback) * sign(close - close[momentum lookback])), pressure smoothing lookback)
Long: directional pressure >= minimum absolute directional pressure
Short: directional pressure <= -minimum absolute directional pressure
Long: directional pressure crosses above minimum absolute directional pressure
Short: directional pressure crosses below -minimum absolute directional pressure