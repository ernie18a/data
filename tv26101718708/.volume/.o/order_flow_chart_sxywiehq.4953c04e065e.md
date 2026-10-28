Calculation: Estimated buy volume = if high > low, volume × (close − low) / (high − low); otherwise volume × 0.5
Calculation: Smoothed volume delta = EMA(2 × estimated buy volume − volume, smoothing lookback)
Calculation: Cumulative delta = running sum of smoothed volume delta, reset to zero at the start of each day
Calculation: Smoothed buy pressure = EMA(estimated buy volume / volume × 100, shorter lookback)
Long: smoothed volume delta > 0
Short: smoothed volume delta ≤ 0
Long: volume ≥ average volume × block multiplier AND close ≥ open
Short: volume ≥ average volume × block multiplier AND close < open
Long: smoothed buy pressure ≥ imbalance threshold
Short: smoothed buy pressure ≤ 100 − imbalance threshold
Long: cumulative delta crosses above 0
Short: cumulative delta crosses below 0
Long: cumulative delta > 0 AND smoothed buy pressure > 50
Short: cumulative delta < 0 AND smoothed buy pressure < 50
Long: close > daily VWAP
Short: close ≤ daily VWAP