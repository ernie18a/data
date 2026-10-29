Calculation: Drift = SMA(log(close / previous close), longer lookback) - 0.5 × [standard deviation(log(close / previous close), same lookback)]²
Calculation: Trailing stop = maximum of the previous trailing stop and current low minus ATR × multiplier
Long: volume > SMA(volume, longer lookback) × relative-volume multiplier AND ATR < SMA(ATR, same lookback) + standard deviation(ATR, same lookback) AND ATR > SMA(ATR, same lookback) - standard deviation(ATR, same lookback) AND Drift > previous bar's Drift
Exit: Long, low <= Trailing stop