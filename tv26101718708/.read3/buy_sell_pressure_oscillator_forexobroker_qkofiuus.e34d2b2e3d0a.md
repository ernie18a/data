Calculation: Pressure oscillator = if SMA(volume, volume-normalization lookback) > 0 then 100 × EMA((volume or 0) × (2 × (if high > low then (close − low) / (high − low) else 0.5) − 1, pressure-smoothing lookback) / SMA(volume, volume-normalization lookback) else 0
Long: Pressure oscillator > 0
Short: Pressure oscillator < 0
Long: Pressure oscillator ≥ strong-pressure threshold
Short: Pressure oscillator ≤ −strong-pressure threshold
Long: Pressure oscillator crosses above zero
Short: Pressure oscillator crosses below zero
Long: Pressure oscillator ≥ strong-pressure threshold AND its prior-bar value < strong-pressure threshold
Short: Pressure oscillator ≤ −strong-pressure threshold AND its prior-bar value > −strong-pressure threshold
Long: close crosses above EMA(close, reclaim lookback)
Short: close crosses below EMA(close, reclaim lookback)
Long: session restriction is disabled OR the current chart bar is in the configured session; strong-pressure filter is disabled OR abs(Pressure oscillator) ≥ strong-pressure threshold; (Zero-Cross-Only mode is enabled AND Pressure oscillator crosses above zero) OR (Zero-Cross-Only mode is disabled AND Pressure oscillator > 0 AND close crosses above EMA(close, reclaim lookback)); position is flat or short; at least the cooldown length in chart bars has elapsed since the prior signal; current chart bar is confirmed
Short: session restriction is disabled OR the current chart bar is in the configured session; strong-pressure filter is disabled OR abs(Pressure oscillator) ≥ strong-pressure threshold; (Zero-Cross-Only mode is enabled AND Pressure oscillator crosses below zero) OR (Zero-Cross-Only mode is disabled AND Pressure oscillator < 0 AND close crosses below EMA(close, reclaim lookback)); position is flat or long; at least the cooldown length in chart bars has elapsed since the prior signal; current chart bar is confirmed